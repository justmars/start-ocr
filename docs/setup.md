# Setup

## Key Libraries

Library | Rationale | Notes
--:|:--:|:--
_pdfplumber_ | _pdf → img → str_ | Uses `pypdfium2` for page rendering; `pdfminer.six` for text extraction.
_opencv-python_ | _image manipulation_ | Applies contour/dilation heuristics to locate header and footnote lines.
_pytesseract_ | _img → str (fallback)_ | OCR fallback for pages with no embedded text layer; wraps [Tesseract](https://github.com/tesseract-ocr/tesseract).

## MacOS

Install tesseract via homebrew:

```sh
brew install tesseract
```

## Virtual Environment

Install with [uv](https://docs.astral.sh/uv/):

```sh
uv sync
```

## pytest

Tests are doctests discovered via `--doctest-modules` over `src`. No special environment
variables are required.

```sh
uv run pytest
# or
just test
```

## Dockerfile

The Dockerfile installs tesseract and the project via uv:

```sh
docker build --tag start-ocr . && docker run start-ocr
```

## Github Actions

CI installs tesseract, then runs pre-commit (lint) and pytest (tests) via uv.
No ImageMagick or ghostscript setup is required.
