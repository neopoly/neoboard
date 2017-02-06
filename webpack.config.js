var webpack = require("webpack");
var CommonsChunkPlugin = require("webpack/lib/optimize/CommonsChunkPlugin");
var package = require("./package.json");

var vendors = Object.keys(package.dependencies);
var environment = process.env.MIX_ENV == "prod" ? "production" : "development"

module.exports = {
  entry: {
    application: "./web/static/entry.js",
    vendors: vendors
  },
  devtool: "source-map",
  output: {
    path: "./priv/static/js",
    filename: "[name].js"
  },
  resolve: {
    modules: [
      __dirname + "/web/static/js",
      __dirname + "/web/static/vendor",
      "node_modules"
    ]
  },
  plugins: [
    new CommonsChunkPlugin({
      name: "vendors",
      filename: "vendors.js"
    }),
    new webpack.DefinePlugin({
      "process.env": {
        "NODE_ENV": JSON.stringify(environment)
      }
    })
  ],
  module: {
    loaders: [
    {
     test: /\.scss$/,
     loader: "style-loader!css-loader!sass-loader"
    },
    {
     test: /\.sass$/,
     loader: "style-loader!css-loader!sass-loader?indentedSyntax"
    },
    {
      test: /\.js$/,
      exclude: /node_modules/,
      loader: "babel-loader"
    },
    {
      test: /\.json$/,
      loader: "json-loader"
    }
    ]
  }
};
