import React from "react"
import WidgetMixin from "../widget_mixin"

export default React.createClass({
  mixins: [WidgetMixin("youtube:state")],
  getInitialState() {
    return { url: "" }
  },
  render() {
    return (
      <div className="YoutubeWidget">
        <iframe width="100%" height="100%" src={this.state.url} frameborder="0" allowfullscreen></iframe>
      </div>
    )
  }
 })
