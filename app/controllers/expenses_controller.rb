class ExpensesController < ApplicationController
  before_action :set_expense, only: %i[show edit update destroy]

  def index
    @expenses = Expense.all
  end

  def show
  end
  
  def new
    @expense = Expense.new
  end

  def create
    @expense = Expense.new(expense_params)

    if @expense.save 
      redirect_to @expense
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @expense.update(expense_params)
      redirect_to @expense
    else
      render :edit
    end
  end

  def destroy
    @expense.destroy
    redirect_to root_path
  end

  private

  def set_expense
    @expense = Expense.find(params.expect(:id))
  end

  def expense_params
    params.expect(expense: [ :title, :amount, :spent_on ])
  end
end
