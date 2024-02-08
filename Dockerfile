# syntax=docker/dockerfile:1.2

FROM python:3.11.3-slim-bullseye

ARG IM_VER=7.1.1-15 \
  IM_POLICY=/etc/ImageMagick-7/policy.xml

ENV PYTHONDONTWRITEBYTECODE=1 \
  PYTHONUNBUFFERED=1 \
  MAGICK_HOME=/usr/local/lib/ImageMagick-$IM_VER

RUN apt update \
  && apt install -y \
    build-essential wget pkg-config \
    libxml2-dev zlib1g-dev \
    ghostscript tesseract-ocr tesseract-ocr-fra \
    libjpeg62-turbo-dev libtiff-dev libpng-dev libsm6 libxext6 ffmpeg libfontconfig1 libxrender1 libgl1-mesa-glx libfreetype6-dev \
  && apt clean

RUN mkdir -p /tmp/distr && \
  cd /tmp/distr && \
  wget https://download.imagemagick.org/ImageMagick/download/releases/ImageMagick-$IM_VER.tar.xz && \
  tar xvf ImageMagick-$IM_VER.tar.xz && \
  cd ImageMagick-$IM_VER && \
  ./configure --enable-shared=yes --disable-static --without-perl && \
  make && \
  make install && \
  ldconfig /usr/local/lib && \
  cd /tmp && \
  rm -rf distr

RUN if [ -f $IM_POLICY ] ; then sed -i 's/<policy domain="coder" rights="none" pattern="PDF" \/>/<policy domain="coder" rights="read|write" pattern="PDF" \/>/g' $IM_POLICY ; else echo did not see file $IM_POLICY ; fi

COPY . .
RUN pip3 install -U pip && pip3 install -r requirements.txt && rm requirements.txt
CMD ["pytest", "-ra", "-q", "--cov", "--doctest-modules", "start_ocr"]
