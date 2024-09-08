import { withPluginApi } from "discourse/lib/plugin-api";
import UserField from "admin/models/user-field";

export default {
  name: "intro-video-initializer",
  initialize(container) {
    const site = container.lookup("service:site");
    const store = container.lookup("service:store");

    withPluginApi("1.6.0", (api) => {
      const currentUser = api.getCurrentUser();
      const userFields = site.user_fields;
      const introBannerFieldExists = userFields.some(f => f.name === "Show Intro Banner");

      if (currentUser.admin && !introBannerFieldExists) {
        store
          .createRecord("user-field", {})
          .save({
            name: "Show Intro Banner",
            description: "Show the introductory banner on the homepage",
            editable: true,
            show_on_profile: true,
            field_type: "confirm"
          });
      }
    });
  }
}