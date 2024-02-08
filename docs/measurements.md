# Measurements

Since we'll be using distinct libraries with different formats, pay attention to the kind of measurements involved.

## Unit

Library | Unit | Description | Maximum
--:|:--|:--|:--:
_pdfplumber_ | point | PDF unit | `page.height * page.width` is the size of the page
_opencv_ | pixel | Graphical unit | `im.shape` gets a tuple of image dimensions

!!! Warning

    Convert image's pixels as page points, by first getting image ratio; then apply ratio (percentage)
    to the page's max width / height.

    ```py
    >>> from corpus_unpdf.src.common import get_contours # shortcut custom function
    >>> im_h, im_w, im_d = im.shape # im_h is maximum image height
    >>> test = next(cv2.boundingRect(c) for c in get_contours(im, (50, 10)))
    >>> x, y, w, h = test # see Slicing below
    >>> ratio = y / im_h # `y` coordinate over `im_h` gives a pixel-based ratio
    >>> page_point = ratio * page.height # equivalent point in PDF page
    ```

    See related [discussion](https://stackoverflow.com/a/73404598).

## Boxes

### Slicing opencv

!!! Note "Rectangles for opencv"
    Reference | Expectation | Format | Unit
    :--:|:--:|:--:|:--:
    _cv2.boundingRect()_ | Results in a tuple of four points | (`x`,`y`,`w`,`h`) | pixels

Fields | Meaning
--:|:--
`x` | point in x-axis
`y` | point in y-axis
`w` | width
`h` | height

### Slicing pdfplumber

!!! Note "Rectangles for pdfplumber"
    Reference | Expectation | Format | Unit
    :--:|:--:|:--:|:--:
    _pdfplumber._typing.T_bbox_ | A tuple of four points | (`x0`, `y0`, `x1`, `y1`) | points

Fields | Meaning
--:|:--
`x0` | left-most point in _x-axis_
`x1` | right-most point in _x-axis_
`y0` | top-most point in _y-axis_
`y1` | bottom-most point in _y-axis_
