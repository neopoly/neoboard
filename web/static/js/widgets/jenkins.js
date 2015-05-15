import WidgetMixin from "../widget_mixin"
import LastUpdatedAt from "../last_updated_at"

const MAX_NUMBER_OF_JOBS = 10

export default React.createClass({
  mixins: [WidgetMixin("jenkins:state")],
  getInitialState() {
    return {
      happy: true,
      failed_jobs: []
    }
  },
  render() {
    let cls = classNames("JenkinsWidget", {
      happy: this.state.happy,
      sad: !this.state.happy
    })
    return (
      <div className={cls}>
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
      happy: storeState.failed_jobs.length === 0,
      failed_jobs: storeState.failed_jobs
    }
  },
  _renderStatus() {
    if(this.state.happy) return <div className="status happy">✔</div>
    else return <div className="status sad">☹</div>
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