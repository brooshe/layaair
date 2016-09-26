package laya.d3.core.particle {
	import laya.d3.core.ParticleRender;
	import laya.d3.core.Sprite3D;
	import laya.d3.core.material.Material;
	import laya.d3.core.render.IRenderable;
	import laya.d3.core.render.RenderElement;
	import laya.d3.core.render.RenderQueue;
	import laya.d3.core.render.RenderState;
	import laya.d3.math.Vector3;
	import laya.d3.resource.tempelet.ParticleTemplet3D;
	import laya.display.Node;
	import laya.events.Event;
	import laya.particle.ParticleSettings;
	import laya.utils.Stat;
	
	/**
	 * <code>Particle3D</code> 3D粒子。
	 */
	public class Particle3D extends Sprite3D {
		/**@private 粒子模板。*/
		private var _templet:ParticleTemplet3D
		
		/** @private */
		private var _particleRender:ParticleRender;
		
		/**
		 * 获取粒子模板。
		 * @return  粒子模板。
		 */
		public function get templet():ParticleTemplet3D {
			return _templet;
		}
		
		/**
		 * 获取粒子渲染器。
		 * @return  粒子渲染器。
		 */
		public function get particleRender():ParticleRender {
			return _particleRender;
		}
		
		/**
		 * 创建一个 <code>Particle3D</code> 实例。
		 * @param settings value 粒子配置。
		 */
		public function Particle3D(settings:ParticleSettings) {//暂不支持更换模板和初始化后修改混合状态。
			_particleRender = new ParticleRender(this);
			_particleRender.on(Event.MATERIAL_CHANGED, this, _onMaterialChanged);
			
			
			var material:Material = new Material();
			_particleRender.sharedMaterial = material;
			_templet = new ParticleTemplet3D(this, settings);
			if (settings.blendState === 0)
				material.renderMode = Material.RENDERMODE_TRANSPARENT;
			else if (settings.blendState === 1)
				material.renderMode = Material.RENDERMODE_ADDTIVE;
				
			_changeRenderObject(0);
		}
		
		/** @private */
		private function _changeRenderObject(index:int):RenderElement {
			var renderObjects:Vector.<RenderElement> = _particleRender.renderCullingObject._renderElements;
			
			var renderElement:RenderElement = renderObjects[index];
			(renderElement) || (renderElement = renderObjects[index] = new RenderElement());
			
			var material:Material = _particleRender.sharedMaterials[index];
			(material) || (material = Material.defaultMaterial);//确保有材质,由默认材质代替。
			
			var element:IRenderable = _templet;
			renderElement.mainSortID = 0;
			renderElement.triangleCount = element.triangleCount;
			renderElement.sprite3D = this;
			
			renderElement.element = element;
			renderElement.material = material;
			return renderElement;
		}
		
		/** @private */
		private function _onMaterialChanged(_particleRender:ParticleRender, oldMaterials:Array, materials:Array):void {
			var renderElementCount:int = _particleRender.renderCullingObject._renderElements.length;
			for (var i:int = 0, n:int = materials.length; i < n; i++)
				(i < renderElementCount) && _changeRenderObject(i);
		}
		
		/** @private */
		override protected function _clearSelfRenderObjects():void {
			scene.removeFrustumCullingObject(_particleRender.renderCullingObject);
		}
		
		/** @private */
		override protected function _addSelfRenderObjects():void {
			(scene) && (scene.addFrustumCullingObject(_particleRender.renderCullingObject));
		}
		
		/**
		 * 更新粒子。
		 * @param state 渲染相关状态参数。
		 */
		public override function _update(state:RenderState):void {
			_templet.update(state.elapsedTime);
			state.owner = this;
			
			Stat.spriteCount++;
			_childs.length && _updateChilds(state);
		}
		
		/**
		 * 添加粒子。
		 * @param position 粒子位置。
		 *  @param velocity 粒子速度。
		 */
		public function addParticle(position:Vector3, velocity:Vector3):void {
			Vector3.add(transform.localPosition, position, position);
			_templet.addParticle(position, velocity);
		}
		
		override public function dispose():void {
			super.dispose();
			_particleRender.off(Event.MATERIAL_CHANGED, this, _onMaterialChanged);
		}
	
	}

}