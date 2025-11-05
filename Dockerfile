# מבוסס על CUDA 12.6 אך עם נפח מופחת
FROM nvidia/cuda:12.6.3-cudnn-runtime-ubuntu24.04

# הגדרות מערכת
SHELL ["/bin/bash", "-c"]
ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /

# התקנת כלים חיוניים בלבד
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        python3 python3-pip ffmpeg git curl libgl1 libx11-6 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# התקנת ספריות פייתון חיוניות
RUN pip install --no-cache-dir --upgrade pip setuptools wheel

# התקנת הספריות הנדרשות ל-Faster Whisper + Diarization
RUN pip install --no-cache-dir \
    torch torchaudio \
    faster-whisper \
    pyannote.audio==3.3.1 \
    ffmpeg-python \
    runpod numpy

# העתקת הקבצים שלך
COPY src ./
COPY models models/
COPY test_input.json .

# הפקודה שתפעיל את ה-worker
CMD ["python3", "-u", "rp_handler.py"]
