import React from "react"
import WidgetStore from "./widget_store"
import ReactGridLayout from "react-grid-layout"

export default React.createClass({
  getDefaultProps() {
    return {
      width: 1920,
      cols: 5,
      rowHeight: 350,
      widgets: []
    }
  },
  getInitialState() {
    return {}
  },
  render() {
    const channel = this.props.channel
    let renderWidget = function(configuration, i){
      const widget = configuration[0]
      const grid   = configuration[1]
      const props  = configuration[2] || {}
      props.channel = channel
      return (
        <div key={i} data-grid={grid}>
          {React.createElement(widget, props)}
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
        width={this.props.width}
        margin={[5,5]}
        containerPadding={[5,5]}
      >
        {this.props.widgets.map(renderWidget)}
      </ReactGridLayout>
    )
  }
})
