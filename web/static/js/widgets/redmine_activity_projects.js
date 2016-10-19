import React from "react"
import WidgetMixin from "../widget_mixin"
import LastUpdatedAt from "../last_updated_at"
import {FormattedRelative} from "react-intl"
import classNames from "classnames"

const NEXT_TIMEOUT = 5000 //ms

export default React.createClass({
  mixins: [WidgetMixin("redmine_activity:state")],
  getInitialState() {
    return {
      projects: [],
      highlight: 0
    }
  },
  componentWillMount() {
    setTimeout(this._nextHighlight, NEXT_TIMEOUT)
  },
  render() {
    return (
      <div className="RedmineActivityProjectsWidget">
        <h2>Projects</h2>
        <ol className="projects">
          {this.state.projects.map(this._renderProject)}
        </ol>
        <LastUpdatedAt updated_at={this.state.updated_at}/>
      </div>
    )
  },
  transform(storeState){
    return {
      projects:  storeState.projects,
      highlight: 0
    }
  },
  _nextHighlight() {
    let highlight = (this.state.highlight+1) % this.state.projects.length
    this.setState({
      projects:  this.state.projects,
      highlight: highlight
    })
    setTimeout(this._nextHighlight, NEXT_TIMEOUT)
  },
  _renderProject(project, i) {
    let cls = classNames({
      full: i == this.state.highlight
    })
    return (
      <li key={project.name} className={cls}>
        <span className="name">{project.name}</span>
        <span className="activity">{project.activity}</span>
        <span className="updated_at">
          <FormattedRelative value={project.updated_at}/>
        </span>
        <ol className="users">
          {project.users.map(this._renderUser)}
        </ol>
      </li>
    )
  },
  _renderUser(user) {
    return (
      <li key={user.email}>
        <img src={user.avatar} title={user.name} alt={user.email}/>
      </li>
    )
  }
})
