require "csv"
require "roo"

class SuppliersController < ApplicationController

  def index
    @suppliers = Supplier.order(:name)
  end

  def show
    @supplier = Supplier.find(params[:id])
  end

  def import_items
    @supplier = Supplier.find(params[:id])

    if params[:file].blank?
      flash[:alert] = "Aucun fichier sélectionné."
      return redirect_to supplier_path(@supplier)
    end

    file = params[:file]
    before_count   = @supplier.supplier_items.count
    new_count      = 0
    existing_count = 0
    errors         = []

    begin
      extension = File.extname(file.original_filename).downcase

      rows =
        case extension
        when ".csv"
          CSV.read(file.path, headers: true)
        when ".xlsx", ".xls"
          xlsx = Roo::Spreadsheet.open(file.path)
          xlsx.sheet(0)
        else
          raise "Format non supporté : #{extension}"
        end

      rows.each do |row|
        ean  = row["ean"]&.to_s&.strip
        name = row["name"]&.to_s&.strip
        next if ean.blank?

        existing = @supplier.supplier_items.find_by(ean: ean)

        if existing
          existing_count += 1
          next
        end

        item = @supplier.supplier_items.new(
          ean:  ean,
          name: name
        )

        if item.save
          new_count += 1
        else
          errors << "EAN #{ean} : #{item.errors.full_messages.join(', ')}"
        end
      end

      after_count = @supplier.supplier_items.count

      flash[:notice] =
        "Import terminé : #{new_count} nouveaux EAN ajoutés, " \
        "#{existing_count} déjà présents."

      flash[:ean_before] = before_count
      flash[:ean_new]    = new_count
      flash[:ean_total]  = after_count

      flash[:alert] = "Erreurs : #{errors.join(' ; ')}" if errors.any?

    rescue => e
      flash[:alert] = "Erreur lors de l'import : #{e.message}"
    end

    redirect_to supplier_path(@supplier)
  end

end
