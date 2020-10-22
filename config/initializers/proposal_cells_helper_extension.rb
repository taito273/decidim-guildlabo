# frozen_string_literal: true

module Decidim
  module Proposals
    # Custom helpers, scoped to the proposals engine.
    #
    module ProposalCellsHelper
      include Decidim::Proposals::ApplicationHelper
      include Decidim::Proposals::Engine.routes.url_helpers
      include Decidim::LayoutHelper
      include Decidim::ApplicationHelper
      include Decidim::TranslationsHelper
      include Decidim::ResourceReferenceHelper
      include Decidim::TranslatableAttributes
      include Decidim::CardHelper

      delegate :title, :state, :published_state?, :withdrawn?, :amendable?, :emendation?, to: :model

      def has_actions?
        return context[:has_actions] if context[:has_actions].present?

        proposals_controller? && index_action? && current_settings.votes_enabled? && !model.draft?
      end

      def has_footer?
        return context[:has_footer] if context[:has_footer].present?

        proposals_controller? && index_action? && current_settings.votes_enabled? && !model.draft?
      end

      def proposals_controller?
        context[:controller].class.to_s == "Decidim::Proposals::ProposalsController"
      end

      def comments
        comments = Decidim::Comments::Comment.where(decidim_commentable_id: model.id, decidim_commentable_type: 'Decidim::Proposals::Proposal')
        good_s = 0
        bad_s = 0
        neutral_s = 0

        comments.each do |comment|
          if comment.alignment == 1
            good_s += 1
          elsif comment.alignment == -1
            bad_s += 1
          else
            neutral_s += 1
          end
        end
        {good_s: good_s, bad_s: bad_s, neutral_s: neutral_s}
      end
      
      def index_action?
        context[:controller].action_name == "index"
      end

      def current_settings
        model.component.current_settings
      end

      def component_settings
        model.component.settings
      end

      def current_component
        model.component
      end

      def from_context
        @options[:from]
      end

      def badge_name
        humanize_proposal_state state
      end

      def state_classes
        case state
        when "accepted"
          ["success"]
        when "rejected"
          ["alert"]
        when "evaluating"
          ["warning"]
        when "withdrawn"
          ["alert"]
        else
          ["muted"]
        end
      end
    end
  end
end