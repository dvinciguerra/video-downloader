# frozen_string_literal: true

require 'time'
require 'sucker_punch'
require 'sinatra'
require 'sinatra/reloader' if development?
require 'sinatra/r18n'
require 'json'

$stdout.sync = true

SuckerPunch.logger = Logger.new($stdout)

class DownloadJob
  include SuckerPunch::Job

  def perform(code)
    SuckerPunch.logger.info("Downloading video #{code}")
    output = `mkdir -p public/thumbnails && mkdir -p public/storage && yt-dlp --write-thumbnail -o 'thumbnail:public/thumbnails/#{code} - %(title)s.%(ext)s' -o 'public/storage/#{code} - %(title)s.%(ext)s' #{code}`
    SuckerPunch.logger.info("Download video finished with status #{output}")
  end
end

# R18n::I18n.default = 'en'

class Videos
  def initialize(file)
    @file = file
  end

  def url
    @url ||= @file.sub!(%r{^/?public}, '')
  end

  def code
    @code ||=
      @file.split('/').last.sub(/\..*/, '').match(/^(?<code>[a-zA-Z0-9_\-]+) - /)['code']
  end

  def thumbnail
    @thumbnail ||=
      Dir["public/thumbnails/#{code}*"].first.sub(/^\/?public/, '') rescue '/thumbnails/default.webp'
  end

  def title
    @title ||= @file.split('/').last.sub(/\..*/, '').sub(/^[a-zA-Z0-9_\-]+ - /, '')
  end

  def attributes
    { code:, title:, url:, thumbnail: }
  end

  class << self
    def all
      Dir['public/storage/*'].map do |file|
        new(file)
      end
    end
  end
end

enable :logging
enable :session

set :threaded, true
set :server, :puma
set :environment, ENV['RUBY_ENV']&.to_sym || :development
set :show_exceptions, production? ? false : true

before do
  session[:locale] = params[:locale] || 'en'
end

get '/' do
  videos = Videos.all

  erb :index, locals: { videos: videos, message: params[:message] }
end

post '/downloads' do
  DownloadJob.perform_async(params[:code])

  redirect "/?message=#{t.notify.downloading.content(params[:code])}"
end

get '/css/:name.css' do
  content_type 'text/css'
  erb params[:name].to_sym, layout: false
end

__END__

@@ index
<% if params[:message] %>
  <div class="d-flex align-items-center p-3 my-3 text-white bg-purple rounded shadow-sm">
    <div class="lh-1">
      <h1 class="h6 mb-0 text-white lh-1"><%= t.notify.downloading.title %></h1>
      <small><%= params[:message] %></small>
    </div>
  </div>
<% end %>

<div class="my-3 p-3 bg-body rounded shadow-sm">
  <h6 class="border-bottom pb-2 mb-0"><%= t.page.home.form.title %></h6>
  <div class="d-flex text-body-secondary pt-3">
    <form action="/downloads" method="post" class="w-100">
      <div class="mb-3">
        <label for="code"><%= t.page.home.form.fields.code.label %></label>
        <input type="text" class="form-control" placeholder="" id="code" name="code" aria-label="Youtube URL" aria-describedby="button-addon2" name="url">
      </div>
      <div class="mb-3">
        <button class="btn btn-outline-primary" type="submit" id="button-addon2"><%= t.page.home.form.fields.submit %></button>
      </div>
    </form>
  </div>
</div>

<div class="my-3 p-3 bg-body rounded shadow-sm">
<h6 class="border-bottom pb-2 mb-0"><%= t.page.home.list.title %></h6>

  <% if videos.any? %>
    <% videos.each do |video| %>
      <div class="d-flex text-body-secondary pt-3">
        <img src="<%= video.thumbnail %>" class="bd-placeholder-img flex-shrink-0 me-2 rounded" style="width: 100px; height: 60px;">
        <div class="pb-3 mb-0 small lh-sm border-bottom w-100">
          <div class="d-flex justify-content-between">
            <strong class="text-gray-dark"><%= video.title %></strong>
            <a href="<%= video.url %>"><%= t.page.home.list.item.watch_button %></a>
          </div>
          <!-- span class="d-block">@username</span -->
        </div>
      </div>
    <% end %>
  <% end %>

</div>


@@ layout
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title><%= t.page.title %></title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH" crossorigin="anonymous">

    <meta name="theme-color" content="#712cf9">


    <style>
      .bd-placeholder-img {
        font-size: 1.125rem;
        text-anchor: middle;
        -webkit-user-select: none;
        -moz-user-select: none;
        user-select: none;
      }

      @media (min-width: 768px) {
        .bd-placeholder-img-lg {
          font-size: 3.5rem;
        }
      }

      .b-example-divider {
        width: 100%;
        height: 3rem;
        background-color: rgba(0, 0, 0, .1);
        border: solid rgba(0, 0, 0, .15);
        border-width: 1px 0;
        box-shadow: inset 0 .5em 1.5em rgba(0, 0, 0, .1), inset 0 .125em .5em rgba(0, 0, 0, .15);
      }

      .b-example-vr {
        flex-shrink: 0;
        width: 1.5rem;
        height: 100vh;
      }

      .bi {
        vertical-align: -.125em;
        fill: currentColor;
      }

      .nav-scroller {
        position: relative;
        z-index: 2;
        height: 2.75rem;
        overflow-y: hidden;
      }

      .nav-scroller .nav {
        display: flex;
        flex-wrap: nowrap;
        padding-bottom: 1rem;
        margin-top: -1px;
        overflow-x: auto;
        text-align: center;
        white-space: nowrap;
        -webkit-overflow-scrolling: touch;
      }

      .btn-bd-primary {
        --bd-violet-bg: #712cf9;
        --bd-violet-rgb: 112.520718, 44.062154, 249.437846;

        --bs-btn-font-weight: 600;
        --bs-btn-color: var(--bs-white);
        --bs-btn-bg: var(--bd-violet-bg);
        --bs-btn-border-color: var(--bd-violet-bg);
        --bs-btn-hover-color: var(--bs-white);
        --bs-btn-hover-bg: #6528e0;
        --bs-btn-hover-border-color: #6528e0;
        --bs-btn-focus-shadow-rgb: var(--bd-violet-rgb);
        --bs-btn-active-color: var(--bs-btn-hover-color);
        --bs-btn-active-bg: #5a23c8;
        --bs-btn-active-border-color: #5a23c8;
      }

      .bd-mode-toggle {
        z-index: 1500;
      }

      .bd-mode-toggle .dropdown-menu .active .bi {
        display: block !important;
      }
    </style>


    <link href="/css/offcanvas_navbar.css" rel="stylesheet">
  </head>
  <body class="bg-body-tertiary">
    <nav class="navbar navbar-expand-lg fixed-top navbar-dark bg-dark" aria-label="Main navigation">
      <div class="container-fluid">
        <a class="navbar-brand" href="/"><%= t.page.title %></a>
        <button class="navbar-toggler p-0 border-0" type="button" id="navbarSideCollapse" aria-label="Toggle navigation">
          <span class="navbar-toggler-icon"></span>
        </button>
      </div>
    </nav>

    <div class="nav-scroller bg-body shadow-sm">
      <nav class="nav" aria-label="Secondary navigation">
        <a class="nav-link active" aria-current="page" href="/"><%= t.page.nav.home %></a>
      </nav>
    </div>

    <main class="container">
      <%= yield %>
    </main>

    <script src="/docs/5.3/dist/js/bootstrap.bundle.min.js" integrity="sha384-YvpcrYf0tY3lHB60NNkmXc5s9fDVZLESaAA55NDzOxhy9GkcIdslK1eN7N6jIeHz" crossorigin="anonymous"></script>
  </body>
</html>

@@ offcanvas_navbar
html,
body {
  overflow-x: hidden; /* Prevent scroll on narrow devices */
}

body {
  padding-top: 56px;
}

@media (max-width: 991.98px) {
  .offcanvas-collapse {
    position: fixed;
    top: 56px; /* Height of navbar */
    bottom: 0;
    left: 100%;
    width: 100%;
    padding-right: 1rem;
    padding-left: 1rem;
    overflow-y: auto;
    visibility: hidden;
    background-color: #343a40;
    transition: transform .3s ease-in-out, visibility .3s ease-in-out;
  }
  .offcanvas-collapse.open {
    visibility: visible;
    transform: translateX(-100%);
  }
}

.nav-scroller .nav {
  color: rgba(255, 255, 255, .75);
}

.nav-scroller .nav-link {
  padding-top: .75rem;
  padding-bottom: .75rem;
  font-size: .875rem;
  color: #6c757d;
}

.nav-scroller .nav-link:hover {
  color: #007bff;
}

.nav-scroller .active {
  font-weight: 500;
  color: #343a40;
}

.bg-purple {
  background-color: #6f42c1;
}
