import WidgetMixin from "../widget_mixin"

export default React.createClass({
  mixins: [WidgetMixin("images:state")],
  getInitialState() {
    return {url: ""}
  },
  render() {
    return (
      <div className="ImagesWidget">
        {this.state.url === "" ? undefined : this._renderImage()}
      </div>
    )
  },
  _renderImage(){
    return <img src={this.state.url} />
  }
})
