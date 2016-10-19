import React from "react"
import WidgetMixin from "../widget_mixin"

export default React.createClass({
  mixins: [WidgetMixin("nicht_lustig:state")],
  getInitialState() {
    return { image: "" }
  },
  render() {
    return (
      <div className="NichtLustigWidget">
        <img src={this.state.image} ref={(img) => this._img = img} onLoad={this._handleLoad}/>
        <canvas className="background" ref={(canvas) => this._background = canvas}/>
      </div>
    )
  },
  _handleLoad() {
    if(!this.isMounted()) return
    let canvas  = this._background
    let image   = this._img
    let context = canvas.getContext("2d")
    context.drawImage(image, 1, 1, 2, 2, 0, 0, canvas.width, canvas.height)
  }
})
