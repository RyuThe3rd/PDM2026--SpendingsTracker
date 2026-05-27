enum Tipo{
  Usuario,
  UsuarioPremium,
  Admin
}
//Rui: se precisarmos podemos usar enhanced enums (pesquisem)

enum PeriodoEstatistica {
  semanal,
  mensal,
}

enum FonteTransacao{
  Banco,
  ContaMovel
}

enum TipoDeInsight {
  Investimento,    // Sugestão de Investimento
  Orcamento,       // Gestão de Orçamento
  Eficiencia,      // Eficiência Semanal/Mensal
  Fluxo,           // Reflete "Comparação de Fluxo
  Gastos,         // Padrões de Gastos vs Rendimentos
  Alerta           // Para notificações críticas (sem transações)
}

enum TipoTransacao {
  Deposito,
  Levantamento,
  Consulta
}