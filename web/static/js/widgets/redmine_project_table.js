import React from "react"
import WidgetMixin from "../widget_mixin"
import LastUpdatedAt from "../last_updated_at"

export default React.createClass({
  mixins: [WidgetMixin("redmine_project_table:state")],
  getInitialState() {
    return {
      title: "",
      url: ""
    }
  },
  render() {
    return (
      <div className="RedmineProjectTableWidget">
        <h2>{this.state.title}</h2>
        <img src={this.state.url} />
        <LastUpdatedAt updated_at={this.state.updated_at}/>
      </div>
    )
  }
})
