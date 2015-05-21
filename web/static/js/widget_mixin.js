import WidgetStore from "./widget_store"
import Channel from "./channel"

export default function(channelName) {
  return {
    propTypes: {
      channel: React.PropTypes.instanceOf(Channel).isRequired
    },
    componentWillMount() {
      this.store = new WidgetStore(this.props.channel, channelName);
      this.store.addListener(this._onStoreChange)
    },
    _onStoreChange() {
      let state = this.store.state
      if(_.isFunction(this.transform)) {
        state = this.transform(state)
        if(!state.updated_at) state.updated_at = this.store.state.updated_at
      }
      // allow components to overwrite the default action if a store
      // has changed to do more actions
      if(_.isFunction(this.onStoreChange)) {
        this.onStoreChange(state)
      }else{
        this.setState(state)
      }
    }
  }
}