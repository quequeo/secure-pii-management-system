class PeopleController < ApplicationController
  def index
    @people = Person.order(created_at: :desc).map { |person| PersonPresenter.new(person, view_context) }
  end

  def new
    @person = Person.new
  end

  def create
    @person = Person.new(person_params)
    
    if @person.save
      redirect_to @person, notice: "Person was successfully created."
    else
      render :new, status: :unprocessable_content
    end
  end

  def show
    @person = PersonPresenter.new(Person.find(params[:id]), view_context)
  end

  private

  def person_params
    params.require(:person).permit(
      :first_name,
      :middle_name,
      :last_name,
      :ssn,
      :street_address_1,
      :street_address_2,
      :city,
      :state,
      :zip_code
    )
  end
end
