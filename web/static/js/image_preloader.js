export default class {
  preload(url, callback) {
    this._image = new Image()
    this._image.onload = () => callback()
    this._image.src = url
  }

  cancel() {
    if(this._image) delete this._image.onload
    delete this._image
  }
}
