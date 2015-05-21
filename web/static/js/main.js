import App from "./app"
import TimeWidget from "./widgets/time"
import JenkinsWidget from "./widgets/jenkins"
import NotepadWidget from "./widgets/notepad"
import NichtLustigWidget from "./widgets/nicht_lustig"
import RedmineProjectTable from "./widgets/redmine_project_table"
import Gitter from "./widgets/gitter"
import RedmineActivityProjects from "./widgets/redmine_activity_projects"
import RedmineActivityUsers from "./widgets/redmine_activity_users"
import OwncloudImages from "./widgets/owncloud_images"
import Images from "./widgets/images"

const widgets = [
  // Format:
  // [widget, grid configuration]
  [Gitter,                  {x:0, y:0, w:1, h:2}],
  [RedmineActivityProjects, {x:1, y:0, w:1, h:2}],
  [RedmineActivityUsers,    {x:2, y:0, w:1, h:1}],
  [OwncloudImages,          {x:4, y:1, w:1, h:1}],
  [TimeWidget,              {x:4, y:0, w:1, h:1}],
  [JenkinsWidget,           {x:3, y:0, w:1, h:1}],
  [NichtLustigWidget,       {x:2, y:1, w:1, h:1}],
  [RedmineProjectTable,     {x:0, y:2, w:3, h:1}],
  [NotepadWidget,           {x:3, y:1, w:1, h:2}],
  [Images,                  {x:4, y:2, w:1, h:1}]
]

export default {
  run() {
    React.render(<App widgets={widgets}/>, document.body)
  }
}