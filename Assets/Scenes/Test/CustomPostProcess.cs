using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;
public class CustomPostProcess : ScriptableRendererFeature
{
    [System.Serializable]
    public class CustomPostProcessSettings
    {
        //パスの実行タイミング
        public RenderPassEvent Event = RenderPassEvent.BeforeRenderingPostProcessing;
        //使用するシェーダー
        public Shader GrayScaleShader;
    }

    public CustomPostProcessSettings settings = new CustomPostProcessSettings();

    private CustomPostProcessPass pass;

    // ScriptableRendererFeatureはScriptableObjectとしてRendererData内部に格納される。
    // ScriptableObjectのシリアライズのタイミングで呼ばれる。
    public override void Create()
    {
        this.name = "Custom PostProcess";
        pass = new CustomPostProcessPass(settings.Event, settings.GrayScaleShader);
    }

    //パスの差し込み。URPのSetupで呼ばれる。
    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        
        pass.Setup(renderer.cameraColorTarget, RenderTargetHandle.CameraTarget);
        renderer.EnqueuePass(pass);
    }
}



public class CustomPostProcessPass : ScriptableRenderPass
{
    //CommandBufferの取得に使用する名前
    const string k_RenderCustomPostProcessingTag =
        "Render Custom PostProcessing Effects";

    //入出力
    private RenderTargetIdentifier passSource;
    private RenderTargetHandle passDestination;

    //Blitに使用するマテリアル
    private Material grayScaleMaterial;

    //一時的なレンダーターゲット（パスの入出力が同一の場合、いちど中間バッファを挟んでBlitする必要があるため）
    RenderTargetHandle m_TemporaryColorTexture;

    public CustomPostProcessPass(RenderPassEvent renderPassEvent, Shader grayScaleShader)
    {
        //パスの実行タイミングを指定
        this.renderPassEvent = renderPassEvent;
        if (grayScaleShader)
            grayScaleMaterial = new Material(grayScaleShader);

        //一時バッファの設定
        m_TemporaryColorTexture.Init("_TemporaryColorTexture");
    }

    public void Setup(RenderTargetIdentifier source, RenderTargetHandle destination)
    {
        this.passSource = source;
        this.passDestination = destination;
    }

    public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
    {
        //レンダリング情報（画面サイズなど）。一時バッファの作成に使用。
        RenderTextureDescriptor opaqueDesc = renderingData.cameraData.cameraTargetDescriptor;
        opaqueDesc.depthBufferBits = 0;

        var cmd = CommandBufferPool.Get(k_RenderCustomPostProcessingTag);

        Render(cmd, ref renderingData, opaqueDesc);

        context.ExecuteCommandBuffer(cmd);
        CommandBufferPool.Release(cmd);
    }

    void Render(CommandBuffer cmd, ref RenderingData renderingData, RenderTextureDescriptor opaqueDesc)
    {
        cmd.GetTemporaryRT(m_TemporaryColorTexture.id, opaqueDesc, FilterMode.Bilinear);

        DoEffectGrayScale(cmd, passSource, m_TemporaryColorTexture, opaqueDesc);

        if (passDestination == RenderTargetHandle.CameraTarget)
        {
            Blit(cmd, m_TemporaryColorTexture.Identifier(), passSource);
        }
        else
        {
            Blit(cmd, m_TemporaryColorTexture.Identifier(), passDestination.Identifier());
        }
    }

    private void DoEffectGrayScale(CommandBuffer cmd, RenderTargetIdentifier source, RenderTargetHandle destination,
        RenderTextureDescriptor opaqueDesc)
    {
        Blit(cmd, source, destination.Identifier(), grayScaleMaterial, 0);
    }

    public override void FrameCleanup(CommandBuffer cmd)
    {
        if (passDestination == RenderTargetHandle.CameraTarget)
            cmd.ReleaseTemporaryRT(m_TemporaryColorTexture.id);
    }
}