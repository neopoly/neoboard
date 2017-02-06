import React from "react"
import WidgetMixin from "../widget_mixin"
import LastUpdatedAt from "../last_updated_at"
import Emojify from "emojify.js"
import {FormattedRelative} from "react-intl"
import ReactCSSTransitionGroup from "react-addons-css-transition-group"
import ReactMarkdown from "react-markdown"

const Post = React.createClass({
  getDefaultProps() {
    return { interval: 1000 * 60 } // 1 minute
  },
  render() {
    return (
      <div>
        <div className="avatar">
          <img src={this.props.user.avatar_url}/>
        </div>
        <div className="content">
          <div className="meta">
            <span className="displayName">
              {this.props.user.first_name} {this.props.user.last_name}
            </span>
            <FormattedRelative value={this.props.create_at}/>
          </div>
          <div ref={(p) => this._body = p} className="body">
            <ReactMarkdown source={this.props.message} />
          </div>
        </div>
        <div className="clear"/>
      </div>
    )
  },
  componentDidMount() {
    Emojify.run(this._body)
    this._update()
  },
  componentWillUnmount() {
    this._clearTimeout()
  },
  _update() {
    this._clearTimeout()
    this.timeout = setTimeout(this._update, this.props.interval)
    this.forceUpdate()
  },
  _clearTimeout() {
    if(this.timeout) {
      clearTimeout(this.timeout)
      delete this.timeout
    }
  }
})

export default React.createClass({
  mixins: [WidgetMixin("mattermost:state")],
  getDefaultProps() {
    return {transition: "transitionFade"}
  },
  getInitialState() {
    return {
      title: "",
      posts: []
    }
  },
  render() {
    return (
      <div className="MattermostWidget">
        <h2>{this.state.title}</h2>
        <div className="scrollable">
          <div className="scrollable-content">
            <ReactCSSTransitionGroup
              transitionName={this.props.transition}
              transitionEnterTimeout={500}
              transitionLeaveTimeout={500}
              component="ol">
              {this.state.posts.reverse().map(this._renderPost)}
            </ReactCSSTransitionGroup>
          </div>
        </div>
        <img src={this.state.url} />
        <LastUpdatedAt updated_at={this.state.updated_at}/>
      </div>
    )
  },
  _renderPost(post) {
    return (
      <li key={post.id}>
        <Post {...post}/>
      </li>
    )
  }
})
