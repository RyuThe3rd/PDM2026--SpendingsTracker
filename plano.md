# Plan: Arquitetura de Gestão Dinâmica de Estatísticas Semanais/Mensais

**TL;DR**: Implementar um sistema onde `EstatisticaSemanal` e `EstatisticaMensal` são criados dinamicamente ao abrir a app ou quando a semana/mês muda. Usar IDs explícitos (`weekId`, `monthId`) e referências (`semanaAnteriorId`, `mesAnteriorId`) para rastreamento. Resolver gaps de semanas preenchendo-as automaticamente. Bloquear: coleta passiva de SMS e monitoração contínua.

---

## Decisões Tomadas

| Aspecto | Decisão |
|--------|---------|
| **Transição de Semana** | Opção A: Ao abrir app (TelaHome.initState) |
| **Gaps de Semanas** | Opção B: Preencher automaticamente com entradas vazias |
| **Identificador Único** | Opção C: `weekId` formato `"YYYY-WXX"` (ISO) + `semanaAnteriorId` explícito |
| **Comparação Histórica** | Opção C: Redundância — `semanaAnteriorId` armazenado + busca cronológica como fallback |
| **Agregação Mensal** | Vincular: `EstatisticaMensal.dadosSemanais` deve conter refs aos 4 `EstatisticaSemanal` do mês |

---

## Estrutura de Dados Atualizada

Nota: a estatistica Semanal já tem uma função para inicializar a dataInicio e dataFim

### Adições a `EstatisticaSemanal`
```dart
String weekId;                    // "2026-W22" (formato ISO: YYYY-WXX)
String? semanaAnteriorId;         // ID Firestore do documento anterior (nullable na Semana 1)
DateTime criadoEm;                // Timestamp de criação para auditoria
```

### Adições a `EstatisticaMensal`
```dart
String monthId;                   // "2026-05" (formato: YYYY-MM)
String? mesAnteriorId;            // ID Firestore do mês anterior
List<Map<int,dynamic>> semanasDoMesIds;          // map[1] = idDaSemana1
// Mantenha esta estrutura de lista de IDs Firestore das 4 `EstatisticaSemanal` deste mês
DateTime criadoEm;                // Timestamp de criação
```

### Firestore Schema (Exemplo)
```
Users/{uid}/Estatisticas/
  ├── {autoId1}  →  EstatisticaSemanal
  │   ├── weekId: "2026-W20"
  │   ├── semanaAnteriorId: null
  │   ├── periodo: "semanal"
  │   ├── dataInicio: 2026-05-11
  │   ├── semanaCounter: 2
  │   ├── mes: "5"
  │   └── ...valores...
  │
  ├── {autoId2}  →  EstatisticaSemanal
  │   ├── weekId: "2026-W21"
  │   ├── semanaAnteriorId: "{autoId1}"     ← Ligação explícita
  │   ├── periodo: "semanal"
  │   └── ...
  │
  └── {autoId3}  →  EstatisticaMensal
      ├── monthId: "2026-05"
      ├── mesAnteriorId: null               ← Primeira vez, sem anterior
      ├── periodo: "mensal"
      ├── semanalIds: ["{autoId1}", "{autoId2}", ...]
      └── ...
```

---

## Fases de Implementação

### **Fase 1: Refactor de Modelos**
1. Adicionar método utilitário para gerar `weekId` (baseado em `dataInicio`)
2. **Verificação**: Modelos compilam; testes de serialização passam

### **Fase 2: Lógica de Monitoração de Transição (TelaHome.initState)**
1. Criar novo método `_detectarMudancaSemana()` que:
    - Lê `_semanaAtual.weekId` do provider
    - Calcula `weekIdAtual` com base em `DateTime.now()`
    - Se diferentes:
        - Buscar todas as semanas do gap (ex: W21, W22, W23) que faltam no Firestore
        - Para cada gap: criar `EstatisticaSemanal` vazia com dados = {inicial: último saldo, …}
        - Criar nova `EstatisticaSemanal` para semana atual
        - Atualizar `_semanaAtual` no provider
2. Fazer o mesmo para meses se necessário
3. **Dependência**: *Fase 1 completa*
4. **Verificação**: App abre, semana muda, novas entradas criadas no Firestore

### **Fase 3: Implementar Preenchimento de Gaps**
1. Criar método `_preencherGapsDeSemanasAusentes()` no `EstatisticasRepo`:
    - Recebe `dataInicio` da semana faltante
    - Calcula `valorInicial` = último saldo antes da semana
    - Cria `EstatisticaSemanalModelo` com `valorGanho: 0, valorGasto: 0, diferencaComparativa: 0`
    - Busca transações do período e popula se existirem
    - Guarda no Firestore com `weekId` apropriado
2. **Dependência**: *Fase 2 completa*
3. **Verificação**: Gaps preenchidos; `dadosSemanais` do mês contém todas as 4 semanas

### **Fase 4: Implementar `insightsDeFluxo` Corrigido**
1. Atualizar query para buscar usando `weekId` e `semanaAnteriorId`:
   ```dart
   // Em vez de:
   // .where('periodo', isEqualTo: 'semanal').orderBy('mes', descending: true).limit(1)
   
   // Fazer:
   final semanaAnterior = await collection.doc(estatistica.semanaAnteriorId).get();
   // + fallback: buscar semana imediatamente anterior em cronologia
   ```
2. Atualizar prompt de contexto com dados reais da semana anterior
3. **Dependência**: *Fase 1 + Fase 2*
4. **Verificação**: `insightsDeFluxo` retorna insights com comparação correta

### **Fase 5: Integração com Provider (EstatisticaProvider)**
1. Adicionar método `atualizarEstatisticaSeAtualizada()` que:
    - Checa se semana/mês mudaram
    - Chama `_detectarMudancaSemana()` se necessário
    - Recarrega dados do provider
    - Notifica listeners
2. Chamar esse método no `initState` da `TelaHome` E quando o app é resumida
3. **Dependência**: *Fase 2 + Fase 3*
4. **Verificação**: Provider mantém estado sincronizado com Firestore

---

## Obstáculos Identificados (Fora do Escopo Atual)

### **Obstáculo 0: Coleta de SMS**
**Problema**: Abordagem atual (puxar 50 SMS na abertura) pode perder dados ou duplicar.

**Opções**:
- **Ativa** (atual): `TransacoesRepo.sincronizarSms()` → puxar últimos 50 SMS ao abrir
- **Passiva**: Implementar `BroadcastReceiver` Android que captura SMS em tempo real + persiste localmente

**Impacto em Estatísticas**: Se SMS for passivo, dados chegam continuamente → precisa de atualizar `EstatisticaSemanal` em tempo real (complexo).

**Recomendação para agora**: Manter ativa; revisitar quando houver necessidade de real-time.

---

### **Obstáculo 1: Monitoração Contínua de Transição**
**Problema**: Quando exatamente muda de semana/mês?

**Cenários**:
1. Utilizador abre app terça (W21) → app cria W21
2. Utilizador deixa app aberto até segunda (W22) → estatística ainda em W21
3. Utilizador fecha e reabre na segunda → app deteta muda e cria W22

**Soluções possíveis**:
- **Opção A** (recomendada): Checar transição apenas no `initState`/`onResume` de `TelaHome`
- **Opção B**: Usar `Timer` global que verifica a cada hora
- **Opção C**: Detectar ao navegar entre telas

**Recomendação**: Opção A — simplicidade + bom suficiente para padrão de uso (utilizadores normalmente não deixam app aberto dias inteiros).

---

## Arquivos a Modificar

| Arquivo | O quê | Prioridade |
|---------|-------|-----------|
| [dominio/entidades/estatistica.dart](dominio/entidades/estatistica.dart) | Adicionar `weekId`, `monthId`, `criadoEm` | P0 |
| [data/repositorios/estatisticasRepo.dart](data/repositorios/estatisticasRepo.dart) | Lógica de preenchimento de gaps + queries atualizadas | P0 |
| [presentation/providers/estatisticaProvider.dart](presentation/providers/estatisticaProvider.dart) | Método `atualizarEstatisticaSeAtualizada()` | P1 |
| [presentation/telas/telaHome.dart](presentation/telas/telaHome.dart) | Chamar monitoração de transição no `initState` | P1 |
| [data/servicos/insightsTransacoesService.dart](data/servicos/insightsTransacoesService.dart) | Implementar `insightsDeFluxo` corretamente | P1 |

---

## Verificação (Acceptance Criteria)

1. ✅ Ao abrir app numa semana diferente, nova `EstatisticaSemanal` é criada
2. ✅ Semanas intermediárias são preenchidas (vazio ou com transações se existirem)
3. ✅ `semanaAnteriorId` aponta corretamente para o documento anterior
4. ✅ `insightsDeFluxo` compara com a semana anterior corretamente (sem gaps)
5. ✅ `EstatisticaMensal.dadosSemanais` e `semanalIds` refletem as 4 semanas do mês
6. ✅ Nenhuma semana criada duplicada no Firestore

---

## Decisões Diferidas (Próximas Iterações)

- [ ] Coleta passiva de SMS (BroadcastReceiver)
- [ ] Monitoração contínua de transição (Timer global)
- [ ] Sincronização offline de estadísticas
- [ ] Compressão/arquivo de estatísticas antigas
