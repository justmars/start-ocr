# Setup

## Key Libraries

Library | Rationale | Notes
--:|:--:|:--
_pdfplumber_ | _pdf to img to str_  | Requires `Wand`, `Pillow`, `pdfminer.six`; [Wand](https://docs.wand-py.org/) is dependent on `libmagickwand-dev` for APT on Debian/Ubuntu and `imagemagick` via homebrew Mac.
_opencv-python_ | _img manipulation_ | Wrapper around [OpenCV](https://docs.opencv.org/4.x/) to apply changes to pdf-based images so that it can be prepared for OCR.
_pytesseract_ | _from img to str_| From the [repo](https://github.com/madmaze/pytesseract): Python-tesseract is a wrapper for Google's Tesseract-OCR Engine. It is also useful as a stand-alone invocation script to tesseract, as it can read all image types supported by the Pillow and Leptonica imaging libraries, including jpeg, png, gif, bmp, tiff, and others. Additionally, if used as a script, Python-tesseract will print the recognized text instead of writing it to a file.

## MacOS

### Local Device

Install common libraries in MacOS with `homebrew`:

```sh
brew install tesseract
brew install imagemagick
brew info imagemagick # check version
```

The last command shows the local folder where imagemagick is installed.

  ```sh
  ==> imagemagick: stable 7.1.1-17 (bottled), HEAD # note the version number
  Tools and libraries to manipulate images in many formats
  https://imagemagick.org/index.php
  /opt/homebrew/Cellar/imagemagick/7.1.1-17 (807 files, 31MB) * # first part is the local folder
  x x x
  ```

### Virtual Environment

!!! warning "Update `.env` whenever `imagemagick` changes"

    The shared dependency is based on `MAGICK_HOME` folder. This can't seem to be
    fetched by python (at least in 3.11) so we need to help it along by explicitly
    declaring its location. The folder can change when a new version is installed
    via `brew upgrade imagemagick`

Create an .env file and use the folder as the environment variable `MAGICK_HOME`:

```dotenv
MAGICK_HOME=/opt/homebrew/Cellar/imagemagick/7.1.1-17
```

This configuration allows `pdfplumber` to detect `imagemagick`.

Effect of not setting `MAGICK_HOME`:

```py
>>> import pdfplumber
>>> pdfplumber.open<(testpath>).pages[0].to_image(resolution=300) # ERROR
```

```text
OSError: cannot find library; tried paths: []

During handling of the above exception, another exception occurred:

ImportError                               Traceback (most recent call last)
...
ImportError: MagickWand shared library not found.
You probably had not installed ImageMagick library.
Try to install:
  brew install freetype imagemagick
```

With `MAGICK_HOME`:

```py
>>> import pdfplumber
>>> pdfplumber.open<(testpath>).pages[0].to_image
PIL.Image.Image # image library and type detected
```

Create environment using `poetry install`:

```toml
[tool.poetry.dependencies]
python = "^3.11"
python-dotenv = "^1.0"
pdfplumber = "^0.9"
pillow = "^9.5"
opencv-python = "^4.7"
pytesseract = "^0.3.10"
```

## pytest

Ensure inclusion of `pytest-env`

Add to `pyproject.toml`:

```toml
[tool.pytest.ini_options]
env = ["MAGICK_HOME=/opt/homebrew/Cellar/imagemagick/7.1.1-17"]
```

## Dockerfile

See resources:

1. [ImageMagick](https://imagemagick.org/script/download.php)
2. [Stack Overflow, Ankur](https://stackoverflow.com/a/67088720/21179907)
3. [nickferrando Gist](https://gist.github.com/nickferrando/fb0a44d707c8c3efd92dedd0f79d2911)
4. [Stack Overflow, Shreyesh Desai](https://stackoverflow.com/questions/70504589/imagemagick-installation-in-docker-container-with-external-fonts-for-moviepy/70504590#70504590)

```Dockerfile
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
```

The Dockerfile is intended for testing purposes:

```sh
docker build --tag ocr . && docker run ocr # will run pytest
```

## Github Actions

Note that both `tesseract` and `imagemagick` libraries are also made preconditions in `.github/workflows/main.yaml`:

```yaml title=".github/workflows/main.yaml"
steps:
  # see https://github.com/madmaze/pytesseract/blob/master/.github/workflows/ci.yaml
  - name: Install tesseract
    run: sudo apt-get -y update && sudo apt-get install -y tesseract-ocr tesseract-ocr-fra
  - name: Print tesseract version
    run: echo $(tesseract --version)

  # see https://github.com/jsvine/pdfplumber/blob/stable/.github/workflows/tests.yml
  - name: Install ghostscript & imagemagick
    run: sudo apt update && sudo apt install ghostscript libmagickwand-dev
  - name: Remove policy.xml
    run: sudo rm /etc/ImageMagick-6/policy.xml # this needs to be removed or the test won't run
```
