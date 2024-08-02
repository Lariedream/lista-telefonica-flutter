abstract class TratamentoErro {
  final String mensagem;

  TratamentoErro(this.mensagem);
}

class TelefoneDuplicadoFalha extends TratamentoErro {
  TelefoneDuplicadoFalha(
      [String mensagem = 'O número de telefone já está em uso.'])
      : super(mensagem);
}

class CaracterInvalidoFalha extends TratamentoErro {
  CaracterInvalidoFalha(
      [String mensagem =
          'Por favor, insira um número válido, contendo apenas dígitos!'])
      : super(mensagem);
}

class NomeInvalidoFalha extends TratamentoErro {
  NomeInvalidoFalha(
      [String mensagem =
          'Por favor, digite um nome válido'])
      : super(mensagem);
}
