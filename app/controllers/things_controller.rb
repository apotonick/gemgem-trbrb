class ThingsController < ApplicationController
  respond_to :html

  def new
    form Thing::Create
  end

  def create
    run Thing::Create do |op|
      return redirect_to op.model
    end

    render action: :new
  end

  def show
    present Thing::Update do
      @thing = @model
      form Comment::Create # overrides @model and @form!
    end
  end

  def create_comment
    present Thing::Update do
      @thing = @model
      run Comment::Create # overrides @model and @form!
    end
  end

  def edit
    form Thing::Update

    render action: :new
  end

  def update
    run Thing::Update do |op|
      return redirect_to op.model
    end

    render action: :new
  end
end