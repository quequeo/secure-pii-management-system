class PeopleController < ApplicationController
  before_action :find_person, only: [:show]
  
  rescue_from ActiveRecord::RecordNotFound, with: :person_not_found

  def index
    @people = Person.order(created_at: :desc).map { |person| present(person) }
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
  end

  private

  def find_person
    @person = present(Person.find(params[:id]))
  end

  def present(person)
    PersonPresenter.new(person, view_context)
  end

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

  def person_not_found
    redirect_to people_path, alert: "Person not found."
  end
end
