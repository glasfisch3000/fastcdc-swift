/*
 MIT License

 Copyright (c) 2020 Sylvain Muller & Samuel Aeberhard

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

// Find the middle of the desired chunk size. This is what the
// FastCDC paper refer as "normal size", but with a more adaptive
// threshold based on a combination of average and minimum chunk size
// to decide the pivot point at which to switch masks.
func centerSize(min: Int, avg: Int, max: Int) -> Int {
    let offset = min + ceilDiv(min, 2)
    let size = avg - offset
    return size.bounds(0...max)
}

// integer division that rounds up instead of down
func ceilDiv(_ x: Int, _ y: Int) -> Int {
    (x + y - 1) / y
}
