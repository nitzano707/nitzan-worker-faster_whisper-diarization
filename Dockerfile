# ---------------------------------------------------------
# Dockerfile: Faster-Whisper + PyAnnote (Speaker Diarization)
# ---------------------------------------------------------
FROM nvidia/cuda:12.6.3-cudnn-runtime-ubuntu24.04

# הגדרות בסיסיות
SHELL ["/bin/bash", "-c"]
ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /

# התקנת כלים חיוניים בלבד
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        python3 python3-pip ffmpeg git curl libgl1 libx11-6 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# הגדרת משתנה סביבה עבור Hugging Face
ARG HF_TOKEN
ENV HF_TOKEN=${HF_TOKEN}

# שדרוג pip וכלים נלווים
RUN pip install --no-cache-dir --upgrade pip setuptools wheel --break-system-packages

# התקנת ספריות עיקריות
RUN pip install --no-cache-dir --break-system-packages \
    torch torchaudio \
    faster-whisper \
    pyannote.audio==3.3.1 \
    ffmpeg-python \
    runpod numpy

# בדיקה שהכול נטען בהצלחה (יעצור את הבנייה אם משהו לא עובד)
RUN python3 -c "import torch; from pyannote.audio import Pipeline; print('✅ pyannote.audio loaded successfully with torch', torch.__version__)"

# העתקת הקוד שלך
COPY src ./
COPY models models/
COPY test_input.json .

# פקודת ברירת מחדל — הפעלת ה-worker
CMD ["python3", "-u", "rp_handler.py"]
