import WidgetStore from "./widget_store"
import Channel from "./channel"

export default function(channelName){
  return {
    propTypes: {
      channel: React.PropTypes.instanceOf(Channel).isRequired
    },
    componentWillMount() {
      this.store = new WidgetStore(this.props.channel, channelName);
      this.store.addListener(this._onStoreChange)
    },
    _onStoreChange() {
      this.setState(this.store.state)
    }
  }
}