class AccountsJson {
  int? id;
  final String nome;
  int telefone;
  final DateTime createAt;

  AccountsJson({
    this.id,
    required this.nome,
    required this.telefone,
    required this.createAt,
  });

  factory AccountsJson.fromMap(Map<String, dynamic> json) => AccountsJson(
    id: json["id"],
    nome: json["nome"],
    telefone: json["telefone"],
    createAt: DateTime.parse(json["createAt"]),
  );

  Map<String, dynamic> toMap() => {
    "id": id, 
    "nome": nome,
    "telefone": telefone,
    "createAt": createAt.toIso8601String(),
  };

  Map<String, dynamic> toJson() {
    return {
      'id': id, 
      'nome': nome,
      'telefone': telefone,
    };
  }

  void setId(int id) {
    this.id = id;
  }
}
