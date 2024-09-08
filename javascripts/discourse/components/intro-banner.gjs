import Component from "@glimmer/component";
import bodyClass from "discourse/helpers/body-class";
import DButton from "discourse/components/d-button";
import { service } from "@ember/service";
import { action } from "@ember/object";
import { tracked } from "@glimmer/tracking";
import { fn } from "@ember/helper";
import { on } from "@ember/modifier";
import DiscourseURL from "discourse/lib/url";
import dIcon from "discourse-common/helpers/d-icon";

const bannerLinks = [
  {
    icon: "far-calendar",
    label: "Events Plugin",
    url: "/c/events"
  },
  {
    icon: "question-circle",
    label: "Get Support",
    url: "/new-message?username=angus&title=Support%20Request"
  }
]

export default class IntroBanner extends Component {
  @service router;
  @service currentUser;
  @service site;
  @tracked dismissed = true;

  constructor() {
    super(...arguments);
    this.currentUser.findDetails().then(() => {
      this.dismissed = this.determinedDismissed();
    });
  }

  get show() {
    return this.router.currentRouteName === 'discovery.latest' && !this.dismissed;
  }

  get dismissField() {
    return this.site.user_fields.find(f => f.name === "Show Intro Banner");
  }

  determinedDismissed() {
    if (!this.dismissField) {
      return false;
    }
    if (!this.currentUser.user_fields) {
      return false;
    }
    const userFieldValue = this.currentUser.user_fields[this.dismissField.id];
    if (userFieldValue == undefined) {
      return false;
    }
    return userFieldValue;
  }

  @action
  dismiss() {
    const user = this.currentUser;
    if (!user.user_fields) {
      user.user_fields = {};
    }
    user.user_fields[this.dismissField.id] = true;
    user.save(["user_fields"]);
    this.dismissed = true;
  }

  @action
  bannerLinkClick(url) {
    DiscourseURL.routeTo(url);
  }

  <template>
    {{#if this.show}}
      {{bodyClass "show-intro-banner"}}
      <div class="intro-banner">
        <DButton
          @icon="times"
          @action={{this.dismiss}}
          class="intro-banner-dismiss" />
        <div class="intro-banner-contents">
          <div class="intro-banner-video">
            <iframe
              width="640"
              height="360"
              src="https://www.loom.com/embed/d5137b1154dc4247bae0fc47863cb28b?sid=dbdab025-7699-4dfa-abf2-300f25808654"
              frameborder="0"
              webkitallowfullscreen
              mozallowfullscreen
              allowfullscreen>
            </iframe>
          </div>
          <div class="intro-banner-links">
            {{#each bannerLinks as |link|}}
              <a {{on "click" (fn this.bannerLinkClick link.url)}}>
                {{dIcon link.icon}}
                <h3>{{link.label}}</h3>
              </a>
            {{/each}}
          </div>
        </div>
      </div>
    {{/if}}
  </template>
}