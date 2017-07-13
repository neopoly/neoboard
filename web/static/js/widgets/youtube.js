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
        {this.state.url &&
          <iframe src={this.state.url} allowFullScreen></iframe>
        }
      </div>
    )
  }
 })
