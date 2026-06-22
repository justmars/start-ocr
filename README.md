# start-ocr

![Github CI](https://github.com/justmars/start-ocr/actions/workflows/ci.yml/badge.svg)

Applying pdfplumber + opencv + pytesseract to extract content and metadata from formal PDF files.

- **pdfplumber** renders each PDF page as an image (via pypdfium2) and extracts embedded text.
- **opencv** applies contour/dilation heuristics to locate the header line and footnote separator.
- **pytesseract** is used as a fallback OCR pass on pages with no embedded text layer.

See [documentation](https://justmars.github.io/start-ocr).

## Installation

```sh
uv sync
# or
just install
```
