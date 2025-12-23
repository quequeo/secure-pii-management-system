class PeopleController < ApplicationController
  include Auditable

  before_action :find_person, only: [:show, :edit, :update, :destroy]
  
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
      log_create(@person)
      redirect_to @person, notice: "Person was successfully created."
    else
      render :new, status: :unprocessable_content
    end
  end

  def show
    log_view(@person.model)
  end

  def edit
  end

  def update
    update_params = person_params
    update_params.delete(:ssn) if update_params[:ssn].blank?
    
    if @person.model.update(update_params)
      log_update(@person.model)
      redirect_to @person, notice: "Person was successfully updated."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    person_model = @person.model
    person_model.destroy
    log_destroy(person_model)
    redirect_to people_path, notice: "Person was successfully deleted.", status: :see_other
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
