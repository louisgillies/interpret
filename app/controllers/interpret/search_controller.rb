class Interpret::SearchController < Interpret::BaseController
  before_filter { authorize! :use, :search }

  def index
    if request.post?
      opts = {}
      opts[:key] = params[:key] if params[:key].present?
      opts[:value] = params[:value] if params[:value].present?
      redirect_to interpret_translations_search_url(opts)
    else
      if params[:key].present? || params[:value].present?
        t = Interpret::Translation.arel_table
        search_key = params[:key].present? ? params[:key].split(" ") : []
        search_value = params[:value].present? ? params[:value].split(" ") : []
        if search_value.any? && search_key.any?
          @translations = Interpret::Translation.allowed.locale(I18n.locale).where(t[:key].matches_all(search_key).or(t[:value].matches_all(search_value))).order("translations.key ASC")
        elsif search_key.any?
          @translations = Interpret::Translation.allowed.locale(I18n.locale).where(t[:key].matches_all(search_key)).order("translations.key ASC")
        else
          @translations = Interpret::Translation.allowed.locale(I18n.locale).where(t[:value].matches_all(search_value)).order("translations.key ASC")
        end
      end
    end
  end
end
