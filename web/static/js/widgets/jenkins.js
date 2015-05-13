import WidgetMixin from "../widget_mixin"

export default React.createClass({
  mixins: [WidgetMixin("jenkins:state")],
  getInitialState() {
    return {
      happy: true
    }
  },
  render() {
    let status;
    if(this.state.happy) status = <div>Happy</div>
    else status = <div>Sad</div>
    return (
      <div className="JenkinsWidget">
        {status}
      </div>
    );
  },
  transform(storeState){
    return {
      happy: storeState.failed_jobs.length === 0
    }
  }
})