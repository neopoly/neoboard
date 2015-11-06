import React from "react"
import WidgetMixin from "../widget_mixin"
import LastUpdatedAt from "../last_updated_at"
import TimeoutTransitionGroup from "../timeout_transition_group"

const NEXT_TIMEOUT = 10000 //ms

export default React.createClass({
  mixins: [WidgetMixin("redmineactivity:state")],
  getDefaultProps() {
    return {transition: "transitionSlideFromRight"}
  },
  getInitialState() {
    return {
      users: [],
      highlight: 0
    }
  },
  componentWillMount() {
    setTimeout(this._nextHighlight, NEXT_TIMEOUT)
  },
  render() {
    let user = this._currentUser()
    return (
      <div className="RedmineActivityUsersWidget">
        {user ? this._renderUser(user) : this._renderEmpty()}
        <LastUpdatedAt updated_at={this.state.updated_at}/>
      </div>
    )
  },
  _nextHighlight() {
    let highlight = (this.state.highlight+1) % this.state.users.length
    this.setState({
      users:  this.state.users,
      highlight: highlight
    })
    setTimeout(this._nextHighlight, NEXT_TIMEOUT)
  },
  _renderEmpty(){
    return <div className="empty">Loading…</div>
  },
  _renderUser(user){
    return (
      <TimeoutTransitionGroup
        transitionName={this.props.transition}
        enterTimeout={500}
        leaveTimeout={500}
        component="div"
        className="user">
        <div key={user.email}>
          <img src={this._avatarUrl(user)} />
          <div className="info">
            <h2>{user.name}</h2>
            <ol>
              {user.projects.map(this._renderProject)}
            </ol>
          </div>
        </div>
      </TimeoutTransitionGroup>
    )
  },
  _renderProject(project){
    return <li key={project}><span>{project}</span></li>
  },
  _currentUser(){
    return this.state.users[this.state.highlight]
  },
  _avatarUrl(user){
    return `${user.avatar}?s=400`
  }
})
