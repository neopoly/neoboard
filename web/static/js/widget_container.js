import React from "react"
import WidgetStore from "./widget_store"
import ReactGridLayout from "react-grid-layout"

export default React.createClass({
  getDefaultProps() {
    return {
      width: 1900,
      cols: 5,
      rowHeight: 380,
      widgets: []
    }
  },
  getInitialState() {
    return {}
  },
  render() {
    let channel = this.props.channel
    let renderWidget = function(configuration, i){
      let widget = configuration[0]
      let grid   = configuration[1]
      return (
        <div key={i} data-grid={grid}>
          {React.createElement(widget, {channel: channel})}
        </div>
      )
    }
    return (
      <ReactGridLayout
        className="WidgetContainer"
        cols={this.props.cols}
        rowHeight={this.props.rowHeight}
        isResizable={false}
        isDraggable={false}
        listenToWindowResize={false}
        useCSSTransforms={true}
        width={this.props.width}>
        {this.props.widgets.map(renderWidget)}
      </ReactGridLayout>
    )
  }
})
