import React from "react"
import WidgetMixin from "../widget_mixin"
import ImagePreloader from "../image_preloader"
import TimeoutTransitionGroup from "../timeout_transition_group"

export default React.createClass({
  mixins: [WidgetMixin("owncloudimages:state")],
  getDefaultProps() {
    return {transition: "transitionScaleGrow"}
  },
  getInitialState() {
    return {
      url: "",
      name: "",
      current: 0,
      count: 0
    }
  },
  componentDidMount() {
    this.preloader = new ImagePreloader(this._onImagePreloaded)
  },
  componentWillUnmount() {
    this.preloader.cancel()
  },
  render() {
    return (
      <div className="OwncloudImagesWidget">
        {this.state.url === "" ? this._renderEmpty() : this._renderImage()}
      </div>
    )
  },
  onStoreChange(state) {
    this.preloader.preload(state.url, () => this.setState(state))
  },
  _renderEmpty(){
    return <div className="empty">Loading…</div>
  },
  _renderImage(){
    return (
      <TimeoutTransitionGroup
        transitionName={this.props.transition}
        enterTimeout={500}
        leaveTimeout={500}
        component="div"
        className="image">
        <div key={this.state.url}>
          <div className="background"><img src={this.state.url}/></div>
          <div className="foreground"><img src={this.state.url} alt={this.state.name}/></div>
          <div className="legend">
            <span className="path">{this._path(this.state.path)}</span>
            <span className="counter">{this.state.current} / {this.state.count}</span>
          </div>
        </div>
      </TimeoutTransitionGroup>
    )
  },
  _path(path){
    // transform "/dir_one/dir2" -> "Dir One / Dir2"
    return path.split("/")
      .filter(s => s.length > 0)
      .map(_.startCase)
      .join(" / ")
  }
})
