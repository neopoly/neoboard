use Mix.Config

config :neoboard, Neoboard.Widgets.Time,
  every: 1000

# Uncomment and tweak configuration for widgets you want to use.
# Find samples for a widgets below:

# config :neoboard, Neoboard.Widgets.Notepad,
#   url: "https://internal.company.com/announcements",
#   every: 10000,
#   title: "Neopad",
#   info: "Edit via orga/wiki/DashboardNotepad"

# config :neoboard, Neoboard.Widgets.Jenkins,
#   url: "http://jenkins.company.com/api/json",
#   every: 10000,
#   failed_color: "red"

# config :neoboard, Neoboard.Widgets.GitlabCi,
#   every: 30000,
#   api_url: "https://gitlab.com/api/v3",
#   private_token: "verysecret"

# config :neoboard, Neoboard.Widgets.NichtLustig,
#   url: "http://static.nichtlustig.de/comics/full/",
#   base: "http://static.nichtlustig.de/comics/full/~s.jpg",
#   every: 300_000

# config :neoboard, Neoboard.Widgets.RedmineProjectTable,
#   url: "https://redmine.company.com/projects/the_project/issues/gantt.png?month=~s&months=4&query_id=18&year=~s&zoom=2&r=~s",
#   every: 300_000,
#   title: "Timetable"

# config :neoboard, Neoboard.Widgets.Gitter,
#   room: "cryptic_room_id",
#   token: "your_access_token",
#   messages: 10,
#   every: 10_000,
#   title: "gitter.im/yourRoom"

#config :neoboard, Neoboard.Widgets.Mattermost,
#  api_url: "http://mattermost.company.com/api/v3",
#  login_id: "username_or_email",
#  password: "very_secret",
#  team_id: "your_team_id",
#  channel_id: "the_channel_id",
#  every: 10_000,
#  posts: 10,
#  title: "mattermost/town-square"

# config :neoboard, Neoboard.Widgets.OwncloudImages,
#   url: "https://owncloud.company.com/public.php?service=files&t=SECRET_TOKEN",
#   every: 10_000

# config :neoboard, Neoboard.Widgets.Images,
#   urls: [
#     "http://www.company.com/logo-a.png",
#     "http://www.company.com/logo-b.png",
#   ],
#   every: 10_000
