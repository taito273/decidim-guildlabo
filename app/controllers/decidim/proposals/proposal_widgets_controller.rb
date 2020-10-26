# frozen_string_literal: true

module Decidim
    module Proposals
      class ProposalWidgetsController < Decidim::WidgetsController
        helper Proposals::ApplicationHelper
  
        private
  
        def model
          @model ||= Proposal.where(component: params[:component_id]).find(params[:proposal_id])
        end
  
        def comments
          comments = Decidim::Comments::Comment.where(decidim_commentable_id: model.id, decidim_commentable_type: 'Decidim::Proposals::Proposal')
          good_s = comments.where(alignment: 1).length
          bad_s = comments.where(alignment: -1).length
          neutral_s = comments.where(alignment: 0).length
  
          {good_s: good_s, bad_s: bad_s, neutral_s: neutral_s}
        end
        
        def iframe_url
          @iframe_url ||= proposal_proposal_widget_url(model)
        end
      end
    end
  end