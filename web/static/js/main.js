import React from "react"
import ReactDOM from "react-dom"
import {IntlProvider} from "react-intl"
import App from "./app"
import TimeWidget from "./widgets/time"
import GitlabCiWidget from "./widgets/gitlab_ci"
import NotepadWidget from "./widgets/notepad"
import NichtLustigWidget from "./widgets/nicht_lustig"
import YoutubeWidget from "./widgets/youtube"
import RedmineProjectTable from "./widgets/redmine_project_table"
import Gitter from "./widgets/gitter"
import Mattermost from "./widgets/mattermost"
import RedmineActivityProjects from "./widgets/redmine_activity_projects"
import RedmineActivityUsers from "./widgets/redmine_activity_users"
import OwncloudImages from "./widgets/owncloud_images"
import Images from "./widgets/images"

const widgets = [
  // Format:
  // [widget, grid configuration]
  [Mattermost,              {x:0, y:0, w:1, h:2}],
  [RedmineActivityProjects, {x:1, y:0, w:1, h:2}],
  [RedmineActivityUsers,    {x:2, y:0, w:1, h:1}],
  [OwncloudImages,          {x:4, y:1, w:1, h:1}],
  [TimeWidget,              {x:4, y:0, w:1, h:1}],
  [GitlabCiWidget,          {x:3, y:0, w:1, h:1}],
  [YoutubeWidget,           {x:2, y:1, w:1, h:1}],
  //[GiphyWidget,             {x:2, y:1, w:1, h:1}],
  //[NichtLustigWidget,       {x:2, y:1, w:1, h:1}],
  [RedmineProjectTable,     {x:0, y:2, w:3, h:1}],
  [NotepadWidget,           {x:3, y:1, w:1, h:2}],
  [Images,                  {x:4, y:2, w:1, h:1}]
]

const Main = {
  run() {
    ReactDOM.render(
      <IntlProvider locale="en">
        <App widgets={widgets}/>
      </IntlProvider>,
      document.getElementById("main")
    )
  }
}

Main.run()

export default Main
