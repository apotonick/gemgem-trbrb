module Comment::Cell
  class Grid < Trailblazer::Cell
    include Kaminari::Cells
    include ActionView::Helpers::JavaScriptHelper

    def append
      %{ $("#next").replaceWith("#{j(show)}") }
    end

  private
    def page
      options[:page] or 1
    end

    def comments
      # talk about why we don't need an Operation, yet, to collect comments here.
      @comments ||= model.comments.page(page).per(3)
    end
  end
end
