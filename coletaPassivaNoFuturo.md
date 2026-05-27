# Design: Coleta Passiva de SMS para Transações

**Status**: 🔄 Diferido — Documentado para implementação futura  
**Data**: Maio 2026  
**Contexto**: App Flutter com login Firebase Auth

---

## Visão Geral

Sistema que captura SMS de transações **em tempo real** (quando chegam) sem exigir que o utilizador abra a app. Isto complementaria a abordagem ativa atual (puxar 50 SMS na abertura).

### Quando Usar
- ✅ Utilizador quer ver transações instantaneamente no Firestore
- ✅ Projeto requer sincronização quasi-real-time
- ✅ Há recursos para manutenção de código nativo

### Quando NÃO Usar
- ❌ Simplicidade é prioridade (use abordagem ativa)
- ❌ Equipa não é confortável com código nativo Android
- ❌ Budget/timeline é apertado

---

## Arquitetura High-Level

```
┌─────────────────────────────────────────────────────┐
│             SMS Chega no Dispositivo                │
└────────────────┬────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────┐
│  BroadcastReceiver (Android Native - Kotlin)        │
│  - Filtra SMS de M-PESA, E-Mola, MBIM               │
│  - Extrai valor, data, remetente                    │
│  - Tenta acessar Firebase Auth (uid pode estar nil) │
└────────────────┬────────────────────────────────────┘
                 │
         ┌───────┴────────┐
         │                │
    ✅ UID             ❌ UID
   Disponível         Indisponível
         │                │
         ▼                ▼
   ┌──────────────┐  ┌──────────────────┐
   │ Grava direto │  │ Persiste local   │
   │  no Firestore│  │ (SQLite/Hive)    │
   └──────────────┘  └──────────────────┘
         │                │
         └────────┬───────┘
                  ▼
         ┌──────────────────────┐
         │  App abre / Login    │
         │  Sync Local → Cloud  │
         │  Deduplicação        │
         └──────────────────────┘
                  │
                  ▼
         ┌──────────────────────┐
         │ Transação no Firestore│
         │ {uid}/Transações     │
         └──────────────────────┘
```

---

## Componentes Necessários

### 1. **BroadcastReceiver Nativo (Kotlin)**
**Arquivo**: `android/app/src/main/kotlin/com/example/lecc_pdm/SmsReceiver.kt`

```kotlin
package com.example.lecc_pdm

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.telephony.SmsMessage
import android.util.Log
import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.firestore.FirebaseFirestore
import androidx.work.OneTimeWorkRequestBuilder
import androidx.work.WorkManager
import com.google.firebase.firestore.FieldValue
import java.util.concurrent.TimeUnit

class SmsReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context?, intent: Intent?) {
        if (intent?.action == "android.provider.Telephony.SMS_RECEIVED") {
            val bundle = intent.extras ?: return
            val pdus = bundle["pdus"] as Array<*>? ?: return

            for (pdu in pdus) {
                val smsMessage = SmsMessage.createFromPdu(pdu as ByteArray)
                val remetente = smsMessage.originatingAddress ?: ""
                val corpo = smsMessage.messageBody ?: ""
                val timestamp = smsMessage.timestampMillis

                // Filtrar apenas transações
                if (isTransacao(remetente, corpo)) {
                    val transacao = mapOf(
                        "id_sms" to "${remetente}_${timestamp}",
                        "remetente" to remetente,
                        "corpo" to corpo,
                        "data" to timestamp,
                        "valor" to extrairValor(corpo),
                        "sincronizadoEmCloud" to false  // Flag para sync local
                    )

                    // Tentar sincronizar direto (se UID disponível)
                    val uid = FirebaseAuth.getInstance().currentUser?.uid
                    if (uid != null) {
                        sincronizarNoFirestore(context!!, uid, transacao)
                    } else {
                        // Guardar localmente (SQLite)
                        salvarLocalmente(context!!, transacao)
                    }
                }
            }
        }
    }

    private fun isTransacao(remetente: String, corpo: String): Boolean {
        val patterns = listOf("M-PESA", "E MOLA", "MBIM")
        return patterns.any { remetente.uppercase().contains(it) } &&
               corpo.contains(Regex("""\d+[\d.,]*"""))
    }

    private fun extrairValor(body: String): Double {
        val regExp = Regex("""(\d+[\d.,]*)""")
        val match = regExp.find(body)
        return match?.groupValues?.get(0)
            ?.replace(",", "")
            ?.toDoubleOrNull() ?: 0.0
    }

    private fun sincronizarNoFirestore(
        context: Context,
        uid: String,
        transacao: Map<String, Any>
    ) {
        val firestore = FirebaseFirestore.getInstance()
        firestore
            .collection("Users")
            .document(uid)
            .collection("Transações")
            .add(transacao)
            .addOnFailure {
                // Fallback: guardar localmente se Firestore falhar
                salvarLocalmente(context, transacao)
            }
    }

    private fun salvarLocalmente(context: Context, transacao: Map<String, Any>) {
        // Implementar com Room/Hive/SQLite
        // (ver seção abaixo)
        Log.d("SmsReceiver", "Transação salva localmente: ${transacao["id_sms"]}")
    }
}
```

---

### 2. **AndroidManifest.xml - Permissões e Receiver**
**Arquivo**: `android/app/src/main/AndroidManifest.xml`

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Permissões -->
    <uses-permission android:name="android.permission.RECEIVE_SMS" />
    <uses-permission android:name="android.permission.READ_SMS" />
    <uses-permission android:name="android.permission.INTERNET" />

    <application>
        <!-- BroadcastReceiver -->
        <receiver
            android:name=".SmsReceiver"
            android:exported="true"
            android:permission="android.permission.RECEIVE_SMS">
            <intent-filter>
                <action android:name="android.provider.Telephony.SMS_RECEIVED" />
            </intent-filter>
        </receiver>

        <!-- Service para sync em background (WorkManager) -->
        <!-- Configurado via WorkManager API no Kotlin -->

        <!-- ... resto da app ... -->
    </application>
</manifest>
```

---

### 3. **Local Database (Room/Hive)**
**Arquivo**: `android/app/src/main/kotlin/com/example/lecc_pdm/LocalSmsDatabase.kt`

Para persistir SMS que chegarem enquanto UID não está disponível:

```kotlin
package com.example.lecc_pdm

import androidx.room.Database
import androidx.room.Entity
import androidx.room.PrimaryKey
import androidx.room.Room
import androidx.room.RoomDatabase
import android.content.Context

@Entity(tableName = "sms_pendentes")
data class SmsPendente(
    @PrimaryKey val idSms: String,
    val remetente: String,
    val corpo: String,
    val data: Long,
    val valor: Double,
    val sincronizadoEmCloud: Boolean = false,
    val tentativas: Int = 0
)

@Database(entities = [SmsPendente::class], version = 1)
abstract class LocalSmsDatabase : RoomDatabase() {
    abstract fun smsDao(): SmsDao

    companion object {
        @Volatile
        private var INSTANCE: LocalSmsDatabase? = null

        fun getDatabase(context: Context): LocalSmsDatabase {
            return INSTANCE ?: synchronized(this) {
                Room.databaseBuilder(
                    context.applicationContext,
                    LocalSmsDatabase::class.java,
                    "sms_local_db"
                ).build().also { INSTANCE = it }
            }
        }
    }
}

// DAO
import androidx.room.Dao
import androidx.room.Insert
import androidx.room.Query
import androidx.room.Update

@Dao
interface SmsDao {
    @Insert
    suspend fun inserir(sms: SmsPendente)

    @Query("SELECT * FROM sms_pendentes WHERE sincronizadoEmCloud = 0")
    suspend fun obterNaoSincronizados(): List<SmsPendente>

    @Update
    suspend fun atualizar(sms: SmsPendente)

    @Query("DELETE FROM sms_pendentes WHERE idSms = :idSms")
    suspend fun deletar(idSms: String)
}
```

---

### 4. **WorkManager para Sync em Background**
**Arquivo**: `android/app/src/main/kotlin/com/example/lecc_pdm/SmsWorker.kt`

Para sincronizar SMS locais quando a app abre ou periodicamente:

```kotlin
package com.example.lecc_pdm

import android.content.Context
import androidx.work.Worker
import androidx.work.WorkerParameters
import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.firestore.FirebaseFirestore
import kotlinx.coroutines.runBlocking

class SmsWorker(
    context: Context,
    params: WorkerParameters
) : Worker(context, params) {
    override fun doWork(): Result {
        val uid = FirebaseAuth.getInstance().currentUser?.uid
        if (uid == null) {
            // Retry mais tarde quando houver UID
            return Result.retry()
        }

        return runBlocking {
            val db = LocalSmsDatabase.getDatabase(applicationContext)
            val smsPendentes = db.smsDao().obterNaoSincronizados()

            for (sms in smsPendentes) {
                sincronizarNoFirestore(uid, sms, db)
            }

            Result.success()
        }
    }

    private suspend fun sincronizarNoFirestore(
        uid: String,
        sms: SmsPendente,
        db: LocalSmsDatabase
    ) {
        val firestore = FirebaseFirestore.getInstance()
        firestore
            .collection("Users")
            .document(uid)
            .collection("Transações")
            .add(sms.toMap())
            .addOnSuccessListener {
                runBlocking {
                    db.smsDao().deletar(sms.idSms)
                }
            }
            .addOnFailureListener { e ->
                // Incrementar tentativas, retry depois
                runBlocking {
                    db.smsDao().atualizar(
                        sms.copy(tentativas = sms.tentativas + 1)
                    )
                }
            }
    }
}

fun SmsPendente.toMap(): Map<String, Any> {
    return mapOf(
        "id_sms" to idSms,
        "remetente" to remetente,
        "corpo" to corpo,
        "data" to data,
        "valor" to valor
    )
}
```

---

### 5. **Scheduler no MainActivity**
**Arquivo**: `android/app/src/main/kotlin/com/example/lecc_pdm/MainActivity.kt`

Agendar sync quando app abre ou periodicamente:

```kotlin
package com.example.lecc_pdm

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import androidx.work.ExistingPeriodicWorkPolicy
import androidx.work.PeriodicWorkRequestBuilder
import androidx.work.WorkManager
import java.util.concurrent.TimeUnit

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Agendar sync a cada 15 minutos
        val syncRequest = PeriodicWorkRequestBuilder<SmsWorker>(
            15, TimeUnit.MINUTES
        ).build()

        WorkManager.getInstance(this).enqueueUniquePeriodicWork(
            "sms_sync",
            ExistingPeriodicWorkPolicy.KEEP,
            syncRequest
        )

        // Também executar imediatamente quando app abre
        val immediateSync = androidx.work.OneTimeWorkRequestBuilder<SmsWorker>().build()
        WorkManager.getInstance(this).enqueue(immediateSync)
    }
}
```

---

### 6. **Method Channel para Comunicação Flutter ↔ Native**
**Arquivo Kotlin**: `android/app/src/main/kotlin/com/example/lecc_pdm/SmsMethodChannel.kt`

```kotlin
package com.example.lecc_pdm

import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class SmsMethodChannel {
    companion object {
        const val CHANNEL = "com.example.lecc_pdm/sms"

        fun setupChannel(flutterEngine: FlutterEngine) {
            MethodChannel(
                flutterEngine.dartExecutor.binaryMessenger,
                CHANNEL
            ).setMethodCallHandler { call, result ->
                when (call.method) {
                    "getSmsStatus" -> {
                        // Retornar status de SMS pendentes
                        result.success("OK")
                    }
                    "forceSyncSms" -> {
                        // Forçar sync imediatamente
                        WorkManager.getInstance(/* context */)
                            .enqueue(
                                androidx.work.OneTimeWorkRequestBuilder<SmsWorker>()
                                    .build()
                            )
                        result.success(true)
                    }
                    else -> result.notImplemented()
                }
            }
        }
    }
}
```

**Arquivo Dart**: `lib/data/servicos/smsNativeChannel.dart`

```dart
import 'package:flutter/services.dart';

class SmsNativeChannel {
  static const platform = MethodChannel('com.example.lecc_pdm/sms');

  static Future<void> forceSyncSms() async {
    try {
      await platform.invokeMethod('forceSyncSms');
    } catch (e) {
      print('Erro ao forçar sync SMS: $e');
    }
  }

  static Future<String> getSmsStatus() async {
    try {
      return await platform.invokeMethod('getSmsStatus');
    } catch (e) {
      return 'Erro: $e';
    }
  }
}
```

---

## Fluxo Completo de Sincronização

### **Cenário 1: SMS chega, utilizador está logado**
```
1. SMS chega → BroadcastReceiver intercepta
2. UID disponível em FirebaseAuth
3. Grava direto no Firestore/{uid}/Transações
4. Done ✅
```

### **Cenário 2: SMS chega, utilizador NÃO logado**
```
1. SMS chega → BroadcastReceiver intercepta
2. UID não disponível
3. Grava em SQLite local (sms_pendentes)
4. Retorna silenciosamente
```

### **Cenário 3: App abre depois de SMS fora**
```
1. Utilizador faz login
2. MainActivity dispara WorkManager.enqueue(SmsWorker)
3. SmsWorker lê todos os SMS em sms_pendentes
4. Para cada SMS:
   - Tenta sincronizar com Firestore/{uid}/Transações
   - Se sucesso: deleta de local
   - Se falha: incrementa tentativas (retry depois)
5. Próxima sincronização em 15min ou quando app abre
```

---

## Deduplicação

### **Problema**
Se SMS chega e é sincronizado, depois quando o utilizador abre a app e chama `sincronizarSms()` (coleta ativa), pode duplicar.

### **Solução: Campo no Firestore**
```dart
// Modelo atualizado
class TransacoesModelo {
  final String idSms;  // Único por SMS
  final bool sincronizadoEmCloud;
  final DateTime? dataRecebida;  // Timestamp do BroadcastReceiver
  
  // Índice composto no Firestore: {uid, idSms} → Unique
}
```

**Firestore Rules**:
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /Users/{uid}/Transações/{doc=**} {
      // Não permitir duplicatas no mesmo dia
      allow read: if request.auth.uid == uid;
      allow create: if request.auth.uid == uid 
                   && !exists(/databases/$(database)/documents/Users/$(uid)/Transações/
                              where idSms == request.resource.data.idSms);
    }
  }
}
```

---

## Dependências (build.gradle.kts)

```kotlin
dependencies {
    // Firebase
    implementation(platform("com.google.firebase:firebase-bom:34.13.0"))
    implementation("com.google.firebase:firebase-firestore-ktx")
    implementation("com.google.firebase:firebase-auth-ktx")

    // Room (Local DB)
    implementation("androidx.room:room-runtime:2.6.1")
    implementation("androidx.room:room-ktx:2.6.1")
    kapt("androidx.room:room-compiler:2.6.1")

    // WorkManager (Background sync)
    implementation("androidx.work:work-runtime-ktx:2.8.1")

    // Coroutines
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.7.3")
}
```

---

## Configuração no Flutter (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_auth: ^4.10.0
  cloud_firestore: ^4.13.0
```

Não precisa de plugins Flutter adicionais (é tudo nativo + method channels).

---

## Riscos e Mitigações

| Risco | Probabilidade | Impacto | Mitigação |
|-------|--------------|--------|-----------|
| UID null durante BroadcastReceiver | Alta | Médio | SQLite local + sync em bg |
| SMS duplicadas | Média | Alto | `idSms` unique em Firestore |
| Falha de sync em background | Alta | Médio | Retry com WorkManager + log |
| Perda de SMS se BD local corrompida | Baixa | Alto | Backup periódico / redundância |
| Battery drain (sempre a ouvir SMS) | Média | Médio | BroadcastReceiver é eficiente; WorkManager usa batching |

---

## Timeline Estimado

| Fase | Tarefa | Dias |
|------|--------|------|
| 1 | Implementar BroadcastReceiver + Manifest | 1-2 |
| 2 | Configurar Room DB local | 1 |
| 3 | Implementar SmsWorker + WorkManager | 1-2 |
| 4 | Method Channel para Dart | 0.5 |
| 5 | Testes (duplicação, falhas, UID nulo) | 2-3 |
| 6 | Integração com EstatisticaSemanal | 2-3 |
| **Total** | | **7-11 dias** |

---

## Próximos Passos (Se Implementar)

1. ✅ Decidir: Room, Hive, ou SQLite puro?
2. ✅ Testar BroadcastReceiver em emulador
3. ✅ Simular falhas de UID + Firestore
4. ✅ Validar deduplicação
5. ✅ Integrar com transição de semanas (Fase 2-3 do plano principal)
6. ✅ Monitorar battery/data impact em produção

---

## Conclusão

Coleta passiva é **viável mas complexa**. Requer:
- ✅ Código nativo Android (Kotlin)
- ✅ Local database
- ✅ Background job scheduling
- ✅ Method channels
- ✅ Testes robustos de deduplicação

**Recomendação**: Implementar coleta ativa primeiro, completar Fase 1-5 do plano de estatísticas. Passiva pode ser iteração 2 se houver feedback de utilizadores.
