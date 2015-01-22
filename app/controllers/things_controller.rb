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
    present Thing::Update
    form Comment::Create # overrides @model and @form!
    @form.prepopulate!
  end

  def create_comment
    present Thing::Update
    run Comment::Create do |op| # overrides @model and @form!
      flash[:notice] = "Created comment for \"#{op.thing.name}\""
      return redirect_to thing_path(op.thing)
    end

    render :show
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