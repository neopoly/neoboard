import React from "react"
import WidgetMixin from "../widget_mixin"
import ImagePreloader from "../image_preloader"

const ReactCSSTransitionGroup = React.addons.CSSTransitionGroup

export default React.createClass({
  mixins: [WidgetMixin("images:state")],
  getDefaultProps() {
    return {transition: "transitionFade"}
  },
  getInitialState() {
    return {url: ""}
  },
  componentDidMount() {
    this.preloader = new ImagePreloader(this._onImagePreloaded)
  },
  componentWillUnmount() {
    this.preloader.cancel()
  },
  render() {
    return (
      <div className="ImagesWidget">
        <ReactCSSTransitionGroup
          transitionName={this.props.transition}
          component="div">
          {this.state.url === "" ? undefined : this._renderImage()}
        </ReactCSSTransitionGroup>
      </div>
    )
  },
  onStoreChange(state) {
    this.preloader.preload(state.url, () => this.setState(state))
  },
  _renderImage(){
    return (
      <div key={this.state.url} className="image">
        <img src={this.state.url}/>
      </div>
    )
  }
})
