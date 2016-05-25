defmodule HApi.Router do
  use HApi.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug HApi.TokenChecker
  end

  scope "/api", HApi do
    pipe_through :api

    scope "/push" do
      post "/", PushController, :send_push
      post "/message", PushController, :create_message
      post "/token", PushController, :send_token

      get  "/", PushController, :get_push_list
      get  "/:id", PushController, :get_push

      ## push reserved
      post "/reserved/immediate/:id", PushController, :send_immediate_reserved
      delete "/reserved/:id", PushController, :cancel_reserved
      put "/reserved/:id", PushController, :update_reserved
    end

    scope "/services" do

    end

    scope "/mail" do
      post "/", MailController, :send_mail
      delete "/:mail_id", MailController, :cancel_mail
      get "/", MailController, :get_mail_list
      get "/:mail_id", MailController, :get_mail

      scope "/template" do
        post "/", MailTemplateController, :create_template
        get "/", MailTemplateController, :get_template_list
        get "/:template_seq", MailTemplateController, :get_template
        put "/:template_seq", MailTemplateController, :update_template
        delete "/:template_seq", MailTemplateController, :delete_template
      end
    end
  end
end
