import React from "react"
import WidgetMixin from "../widget_mixin"
import LastUpdatedAt from "../last_updated_at"
import classNames from "classnames"

const MAX_NUMBER_OF_JOBS = 4

const BUILD_STATE = {
  happy: "happy",
  sad: "sad",
  unknown: "unknown"
}

export default React.createClass({
  mixins: [WidgetMixin("gitlab_ci:state")],
  getInitialState() {
    return {
      build: BUILD_STATE.unknown,
      failed_jobs: []
    }
  },
  render() {
    return (
      <div className={classNames("GitlabCiWidget", this.state.build)}>
        <h2>CI</h2>
        {this._renderStatus()}
        <ul>
          {this._renderJobs()}
        </ul>
        <LastUpdatedAt updated_at={this.state.updated_at}/>
      </div>
    )
  },
  transform(storeState){
    return {
      build: storeState.failed_jobs.length === 0 ? BUILD_STATE.happy : BUILD_STATE.sad,
      failed_jobs: storeState.failed_jobs
    }
  },
  _renderStatus() {
    return (
      <div className={classNames("status", this.state.build)}>
        {this.state.build === BUILD_STATE.happy && "✔"}
        {this.state.build === BUILD_STATE.sad && "☹"}
        {this.state.build === BUILD_STATE.unknown && "?"}
      </div>
    )
  },
  _renderJobs(){
    let jobs = this.state.failed_jobs.splice(0, MAX_NUMBER_OF_JOBS-1).map(this._renderJob)
    if(this.state.failed_jobs.length > MAX_NUMBER_OF_JOBS) {
      jobs.push(<li key="_more">...</li>)
    }
    return jobs
  },
  _renderJob(job) {
    return (
      <li key={job.name}>
        <a href={job.url}>{job.name}</a>
      </li>
    )
  }
})
