require "csv"
require "roo"

class SuppliersController < ApplicationController
  before_action :set_supplier, only: [:show, :import_items]

  def index
    @suppliers = Supplier.order(:name)
  end

  def show
    # @supplier défini par set_supplier
  end

  def new
    @supplier = Supplier.new
  end

  def create
    @supplier = Supplier.new(supplier_params)

    if @supplier.save
      redirect_to supplier_path(@supplier), notice: "Fournisseur créé avec succès."
    else
      flash.now[:alert] = "Impossible de créer le fournisseur."
      render :new, status: :unprocessable_entity
    end
  end

  def import_items
    if params[:file].blank?
      flash[:alert] = "Aucun fichier sélectionné."
      return redirect_to supplier_path(@supplier)
    end

    file          = params[:file]
    before_count  = @supplier.supplier_items.count
    new_count      = 0
    existing_count = 0
    errors         = []

    begin
      extension = File.extname(file.original_filename).downcase

      headers = []
      rows    = []

      case extension
      when ".csv"
        csv = CSV.read(file.path, headers: true)

        # On normalise les headers en minuscule / sans espaces
        headers = csv.headers.map { |h| h.to_s.strip.downcase }
        Rails.logger.info "IMPORT HEADERS NORMALISES (CSV): #{headers.inspect}"

        # On transforme chaque ligne en hash avec clés normalisées
        rows = csv.map do |row|
          row.to_h.transform_keys { |k| k.to_s.strip.downcase }
        end

      when ".xlsx", ".xls"
        xlsx  = Roo::Spreadsheet.open(file.path)
        sheet = xlsx.sheet(0)

        # Ligne 1 = headers
        headers = sheet.row(1).map { |h| h.to_s.strip.downcase }
        Rails.logger.info "IMPORT HEADERS NORMALISES (XLSX): #{headers.inspect}"

        data_rows = []
        (2..sheet.last_row).each do |i|
          row_values = sheet.row(i).map { |v| v.to_s }
          row_hash   = headers.zip(row_values).to_h
          data_rows << row_hash
        end

        rows = data_rows
      else
        raise "Format non supporté : #{extension}"
      end

      # Petit log des 5 premières lignes pour debug
      Rails.logger.info "IMPORT SAMPLE ROWS:"
      rows.first(5).each_with_index do |row, i|
        Rails.logger.info "ROW #{i + 1}: #{row.inspect}"
      end

      # 1) Vérification des colonnes obligatoires
      required_headers = %w[ean ref nom coloris taille]
      missing_headers  = required_headers - headers

      if missing_headers.any?
        flash[:alert] =
          "Colonnes manquantes ou mal nommées : #{missing_headers.join(', ')}. " \
          "Colonnes attendues : #{required_headers.join(', ')}."

        return redirect_to supplier_path(@supplier)
      end

      # 2) On peut lancer l'import
      rows.each do |row|
        # row est maintenant toujours un Hash avec des clés en minuscule
        raw_ean = row["ean"]
        ref     = normalize_ref(row["ref"])
        nom     = row["nom"].to_s
        coloris = row["coloris"].to_s
        taille  = row["taille"].to_s
        name    = row["name"].to_s if row.key?("name")

        ean = normalize_ean(raw_ean)

        if ean.nil?
          errors << "EAN invalide pour le fournisseur #{@supplier.name} : #{raw_ean.inspect}"
          next
        end

        existing = @supplier.supplier_items.find_by(ean: ean)

        if existing
          existing_count += 1

          # Mise à jour "douce" si nouvelles infos (on ne remplace que si on a quelque chose)
          existing.update(
            ref:     ref.presence     || existing.ref,
            nom:     nom.presence     || existing.nom,
            coloris: coloris.presence || existing.coloris,
            taille:  taille.presence  || existing.taille,
            name:    name.presence    || existing.name
          )

          next
        end

        item = @supplier.supplier_items.new(
          ean:     ean,
          ref:     ref,
          nom:     nom,
          coloris: coloris,
          taille:  taille,
          name:    name
        )

        if item.save
          new_count += 1
        else
          errors << "EAN #{ean} : #{item.errors.full_messages.join(', ')}"
        end
      end

      after_count   = @supplier.supplier_items.count
      ignored_count = errors.size

      flash[:notice] =
        "Import terminé : #{new_count} nouveaux EAN ajoutés, " \
        "#{existing_count} déjà présents, " \
        "#{ignored_count} lignes ignorées (EAN vide ou invalide)."

      flash[:ean_before] = before_count
      flash[:ean_new]    = new_count
      flash[:ean_total]  = after_count

      if errors.any?
        Rails.logger.warn "[IMPORT SUPPLIER #{@supplier.id} - #{@supplier.name}] " \
                          "Erreurs sur #{errors.size} lignes :\n" \
                          "#{errors.join("\n")}"

        sample = errors.first(5).join(" ; ")

        flash[:alert] =
          "Erreurs sur #{errors.size} lignes lors de l'import. " \
          "Exemples : #{sample}"
      end

    rescue => e
      flash[:alert] = "Erreur lors de l'import : #{e.message}"
    end

    redirect_to supplier_path(@supplier)
  end

  private

  def set_supplier
    @supplier = Supplier.find(params[:id])
  end

  def supplier_params
    params.require(:supplier).permit(:name, :code)
  end

  # Normalise un EAN brut venant du fichier (CSV/Excel)
  def normalize_ean(raw_ean)
    return nil if raw_ean.nil?

    str    = raw_ean.to_s.strip
    digits = str.gsub(/\D/, "") # enlève . et tout sauf les chiffres

    # Cas typique: 14 chiffres qui finissent par 0 => bug ".0" d'Excel
    if digits.length == 14 && digits.end_with?("0")
      digits = digits[0, 13]
    end

    # On n'accepte que des EAN-13
    return digits if digits.length == 13

    nil
  end

  # Normalise une ref brute : vire le ".0" Excel si besoin
  def normalize_ref(raw_ref)
    return nil if raw_ref.nil?

    str = raw_ref.to_s.strip

    # Cas Excel classique : "123.0" → "123"
    if str =~ /\A\d+\.0\z/
      return str.sub(/\.0\z/, "")
    end

    # Si c'est un code alphanumérique, on vire juste un éventuel ".0" de fin
    str.sub(/\.0\z/, "")
  end
end
