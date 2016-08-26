class AgregaSupracategoriaACategoriaprensa < ActiveRecord::Migration
  def up
    add_column :sal7711_gen_categoriaprensa, :supracategoria, :boolean, 
      default: false
    execute <<-SQL
INSERT INTO sal7711_gen_categoriaprensa (id, codigo, nombre, fechacreacion, created_at, supracategoria) VALUES ('1', 'A', 'IGLESIA Y CONFLICTO', '2015-05-11', '2015-05-29', 't');
INSERT INTO sal7711_gen_categoriaprensa (id, codigo, nombre, fechacreacion, created_at, supracategoria) VALUES ('2', 'A1', 'La Iglesia Católica y otras Iglesias', '2015-05-11', '2015-05-29', 't');
INSERT INTO sal7711_gen_categoriaprensa (id, codigo, nombre, fechacreacion, created_at, supracategoria) VALUES ('5', 'B', 'POLÍTICA Y GOBIERNO', '2015-05-11', '2015-05-29', 't');
INSERT INTO sal7711_gen_categoriaprensa (id, codigo, nombre, fechacreacion, created_at, supracategoria) VALUES ('6', 'BA1', 'Reformas del Estado', '2015-05-11', '2015-05-29', 't');

INSERT INTO sal7711_gen_categoriaprensa (id, codigo, nombre, fechacreacion, created_at, supracategoria) VALUES ('14', 'B2', 'Congreso: Cámara y Senado', '2015-05-11', '2015-05-29', 't');

INSERT INTO sal7711_gen_categoriaprensa (id, codigo, nombre, fechacreacion, created_at, supracategoria) VALUES ('21', 'B3', 'Gobierno Nacional', '2015-05-11', '2015-05-29', 't');
INSERT INTO sal7711_gen_categoriaprensa (id, codigo, nombre, fechacreacion, created_at, supracategoria) VALUES ('31', 'B4', 'Administración departamental y municipal', '2015-05-11', '2015-05-29', 't');
INSERT INTO sal7711_gen_categoriaprensa (id, codigo, nombre, fechacreacion, created_at, supracategoria) VALUES ('38', 'B5', 'Problemas de la Administración Pública', '2015-05-11', '2015-05-29', 't');
INSERT INTO sal7711_gen_categoriaprensa (id, codigo, nombre, fechacreacion, created_at, supracategoria) VALUES ('43', 'B6', 'Administración y Gobierno de Bogotá', '2015-05-11', '2015-05-29', 't');
INSERT INTO sal7711_gen_categoriaprensa (id, codigo, nombre, fechacreacion, created_at, supracategoria) VALUES ('49', 'B7', 'Administración de Justicia', '2015-05-11', '2015-05-29', 't');
INSERT INTO sal7711_gen_categoriaprensa (id, codigo, nombre, fechacreacion, created_at, supracategoria) VALUES ('58', 'B8', 'Organismos de Control y Ministerio Público', '2015-05-11', '2015-05-29', 't');
INSERT INTO sal7711_gen_categoriaprensa (id, codigo, nombre, fechacreacion, created_at, supracategoria) VALUES ('65', 'B9', 'Fuerza Pública', '2015-05-11', '2015-05-29', 't');
INSERT INTO sal7711_gen_categoriaprensa (id, codigo, nombre, fechacreacion, created_at, supracategoria) VALUES ('69', 'B10', 'Partidos Políticos', '2015-05-11', '2015-05-29', 't');
INSERT INTO sal7711_gen_categoriaprensa (id, codigo, nombre, fechacreacion, created_at, supracategoria) VALUES ('77', 'B11', 'Conflicto Armado y Acciones por la Paz', '2015-05-11', '2015-05-29', 't');
INSERT INTO sal7711_gen_categoriaprensa (id, codigo, nombre, fechacreacion, created_at, supracategoria) VALUES ('88', 'B12', 'Elecciones y Candidatos', '2015-05-11', '2015-05-29', 't');
INSERT INTO sal7711_gen_categoriaprensa (id, codigo, nombre, fechacreacion, created_at, supracategoria) VALUES ('99', 'B13', 'Política Social', '2015-05-11', '2015-05-29', 't');
INSERT INTO sal7711_gen_categoriaprensa (id, codigo, nombre, fechacreacion, created_at, supracategoria) VALUES ('104', 'C', 'NARCOTRAFICO', '2015-05-11', '2015-05-29', 't');
INSERT INTO sal7711_gen_categoriaprensa (id, codigo, nombre, fechacreacion, created_at, supracategoria) VALUES ('105', 'C1', 'Narcotráfico', '2015-05-11', '2015-05-29', 't');
INSERT INTO sal7711_gen_categoriaprensa (id, codigo, nombre, fechacreacion, created_at, supracategoria) VALUES ('113', 'D', 'SOCIEDAD Y CULTURA', '2015-05-11', '2015-05-29', 't');
INSERT INTO sal7711_gen_categoriaprensa (id, codigo, nombre, fechacreacion, created_at, supracategoria) VALUES ('114', 'DA1', 'Grupos étnicos y Culturales', '2015-05-11', '2015-05-29', 't');
INSERT INTO sal7711_gen_categoriaprensa (id, codigo, nombre, fechacreacion, created_at, supracategoria) VALUES ('118', 'D2', 'Conflictos de Trabajo', '2015-05-11', '2015-05-29', 't');
INSERT INTO sal7711_gen_categoriaprensa (id, codigo, nombre, fechacreacion, created_at, supracategoria) VALUES ('127', 'D3', 'Política y Desarrollo Urbano', '2015-05-11', '2015-05-29', 't');
INSERT INTO sal7711_gen_categoriaprensa (id, codigo, nombre, fechacreacion, created_at, supracategoria) VALUES ('136', 'D4', 'Servicios Públicos', '2015-05-11', '2015-05-29', 't');
INSERT INTO sal7711_gen_categoriaprensa (id, codigo, nombre, fechacreacion, created_at, supracategoria) VALUES ('143', 'D5', 'Movilización Social Urbana', '2015-05-11', '2015-05-29', 't');
INSERT INTO sal7711_gen_categoriaprensa (id, codigo, nombre, fechacreacion, created_at, supracategoria) VALUES ('151', 'D6', 'Política y Desarrollo Rural', '2015-05-11', '2015-05-29', 't');
INSERT INTO sal7711_gen_categoriaprensa (id, codigo, nombre, fechacreacion, created_at, supracategoria) VALUES ('162', 'D7', 'Movilización Social Campesina', '2015-05-11', '2015-05-29', 't');
INSERT INTO sal7711_gen_categoriaprensa (id, codigo, nombre, fechacreacion, created_at, supracategoria) VALUES ('169', 'D8', 'Género, Juventud e Infancia', '2015-05-11', '2015-05-29', 't');
INSERT INTO sal7711_gen_categoriaprensa (id, codigo, nombre, fechacreacion, created_at, supracategoria) VALUES ('176', 'D9', 'Acciones colectivas de Gremios, Empresarios,Trabajadores independientes', '2015-05-11', '2015-05-29', 't');
INSERT INTO sal7711_gen_categoriaprensa (id, codigo, nombre, fechacreacion, created_at, supracategoria) VALUES ('182', 'D10', 'Políticas Educativas y Movilizaciones Estudiantiles', '2015-05-11', '2015-05-29', 't');
DELETE FROM sal7711_gen_categoriaprensa WHERE id='186';
INSERT INTO sal7711_gen_categoriaprensa (id, codigo, nombre, fechacreacion, created_at, supracategoria) VALUES ('186', 'D11', 'Conflictos Globales', '2015-05-11', '2015-05-29', 't');
INSERT INTO sal7711_gen_categoriaprensa (id, codigo, nombre, fechacreacion, created_at, supracategoria) VALUES ('189', 'E', 'ECOLOGÍA Y AMBIENTE', '2015-05-11', '2015-05-29', 't');
INSERT INTO sal7711_gen_categoriaprensa (id, codigo, nombre, fechacreacion, created_at, supracategoria) VALUES ('190', 'E1', 'Política Ambiental', '2015-05-11', '2015-05-29', 't');
INSERT INTO sal7711_gen_categoriaprensa (id, codigo, nombre, fechacreacion, created_at, supracategoria) VALUES ('194', 'E2', 'Condiciones, Ambientales de Vida y Trabajo', '2015-05-11', '2015-05-29', 't');
INSERT INTO sal7711_gen_categoriaprensa (id, codigo, nombre, fechacreacion, created_at, supracategoria) VALUES ('198', 'E3', 'Movilizaciones Ambientales', '2015-05-11', '2015-05-29', 't');
    SQL
  end
  def down
    execute <<-SQL
    DELETE FROM sal7711_gen_categoriaprensa WHERE supracategoria='t';
    SQL
    remove_column :sal7711_gen_categoriaprensa, :supracategoria
  end
end
