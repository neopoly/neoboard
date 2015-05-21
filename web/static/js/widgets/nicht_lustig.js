import WidgetMixin from "../widget_mixin"

export default React.createClass({
  mixins: [WidgetMixin("nichtlustig:state")],
  getInitialState() {
    return { image: "" }
  },
  render() {
    return (
      <div className="NichtLustigWidget">
        <img src={this.state.image} ref="image" onLoad={this._handleLoad}/>
        <canvas className="background" ref="background"/>
      </div>
    )
  },
  _handleLoad() {
    if(!this.isMounted()) return
    let canvas  = this.refs.background.getDOMNode()
    let image   = this.refs.image.getDOMNode()
    let context = canvas.getContext("2d")
    context.drawImage(image, 1, 1, 2, 2, 0, 0, canvas.width, canvas.height)
  }
})